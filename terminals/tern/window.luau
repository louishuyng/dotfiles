local tern = require("tern")

-- Keep Tern's native shortcuts alongside Herdr's Ctrl+A table.
local bindings = {
  h = "focus_pane:left", j = "focus_pane:down", k = "focus_pane:up", l = "focus_pane:right",
  ["ctrl+h"] = "previous_tab", ["ctrl+l"] = "next_tab",
  ["ctrl+c"] = "new_session", [","] = "rename_tab", ["shift+4"] = "rename_session",
  v = "open_scrollback", tab = "plugin.tool-keys.last_pane",
  ["shift+s"] = "preferences", ["ctrl+g"] = "goto_directory",
  ["ctrl+shift+r"] = "reload_config",
  ["shift+,"] = "move_tab_left", ["shift+."] = "move_tab_right",
  ["\\"] = "split_right", ["-"] = "split_down",
  z = "zoom", x = "close_pane", ["shift+x"] = "close_tab", c = "new_tab",
  b = "toggle_sidebar", w = "switch_session", ["shift+/"] = "show_commands",
  ["shift+tab"] = "previous_pane", o = "inbox",
}
for key, action in bindings do
  tern.bind("ctrl+a>" .. key, action)
end
for n = 1, 9 do
  tern.bind("ctrl+a>" .. n, "goto_tab:" .. n)
end

local function is_neovim(process)
  return process and (process.name == "nvim"
    or string.match(process.argv[1] or "", "[^/]+$") == "nvim")
end

tern.command({
  id = "toggle_files",
  title = "Toggle Files (preserve Neovim shortcut)",
  run = function(cx)
    local pane = cx.session:focused()
    local row = pane and cx.session:pane(pane)
    if not row or (row.kind ~= "terminal" and row.kind ~= "agent") then
      cx:action("files")
      return
    end
    -- Daemon pane metadata names the shell, not its foreground editor.
    tern.process.run({ "/Applications/Tern.app/Contents/MacOS/tern", "process", tostring(pane), "--json" }, function(result, fresh)
      if fresh.session:focused() ~= pane then return end
      if result.status ~= 0 then
        fresh:toast("error", "Could not inspect pane", result.stderr)
        return
      end
      local process = tern.json.decode(result.stdout)
      if is_neovim(process.child) or is_neovim(process.foreground) then
        fresh:action("text:\28")
      else
        fresh:action("files")
      end
    end)
  end,
})

local function command(id, title, key, run)
  tern.command({ id = id, title = title, keys = { "ctrl+a>" .. key }, run = run })
end

for key, dir in { H = "left", J = "down", K = "up", L = "right" } do
  command("resize_" .. dir, "Resize pane " .. dir, "shift+" .. string.lower(key), function(cx)
    local pane = cx.session:focused()
    if pane then cx.layout:resize(pane, dir, 3) end
  end)
end

for key, dir in { left = "left", down = "down", up = "up", right = "right" } do
  command("swap_" .. dir, "Swap pane " .. dir, key, function(cx)
    local pane = cx.session:focused()
    if not pane then return end
    cx:action("focus_pane:" .. dir)
    local neighbor = cx.session:focused()
    if neighbor and neighbor ~= pane then cx.layout:move(pane, neighbor, "swap") end
    cx.layout:focus(pane)
  end)
end

local function leaves(node, panes)
  if node.pane then
    table.insert(panes, node.pane)
  else
    leaves(node[1], panes)
    leaves(node[2], panes)
  end
end
for key, step in { ["shift+["] = -1, ["shift+]"] = 1 } do
  command("swap_" .. (step < 0 and "previous" or "next"), "Swap with " .. (step < 0 and "previous" or "next") .. " pane", key, function(cx)
    local pane = cx.session:focused()
    local tab = pane and cx.session:tab_of(pane)
    local layout = tab and cx.session:layout(tab)
    if not layout then return end
    local panes = {}
    leaves(layout.root, panes)
    for i, id in panes do
      if id == pane then
        cx.layout:move(pane, panes[(i - 1 + step) % #panes + 1], "swap")
        return
      end
    end
  end)
end

local current, previous = {}, {}
tern.on("window_start", function(cx)
  local pane = cx.session:focused()
  local tab = pane and cx.session:tab_of(pane)
  if tab then current[tab] = pane end
end)
tern.on("focus", function(ev)
  if current[ev.tab] ~= ev.pane then
    previous[ev.tab], current[ev.tab] = current[ev.tab], ev.pane
  end
end)
tern.on("tab_closed", function(ev)
  current[ev.tab], previous[ev.tab] = nil, nil
end)
command("last_pane", "Focus last pane", "tab", function(cx)
  local pane = cx.session:focused()
  local tab = pane and cx.session:tab_of(pane)
  local last = tab and previous[tab]
  if last and cx.session:tab_of(last) == tab then cx.layout:focus(last) end
end)

-- Herdr workspaces correspond to Tern sessions on the current host.
local function sessions(cx)
  local host = cx.sessions:current().host
  local rows = {}
  for _, row in cx.sessions:list() do
    if row.host == host then table.insert(rows, row) end
  end
  return rows
end
for key, step in { ["ctrl+k"] = -1, ["ctrl+j"] = 1 } do
  command(step < 0 and "previous_session" or "next_session", step < 0 and "Previous workspace" or "Next workspace", key, function(cx)
    local rows = sessions(cx)
    for i, row in rows do
      if row.current then
        cx.sessions:switch(rows[(i - 1 + step) % #rows + 1].id)
        return
      end
    end
  end)
end
for n = 1, 9 do
  command("session_" .. n, "Switch workspace " .. n, "shift+" .. n, function(cx)
    local row = sessions(cx)[n]
    if row then cx.sessions:switch(row.id) end
  end)
end

local function project_path(path)
  local home = tern.getenv("HOME")
  if home and (path == "~" or string.sub(path, 1, 2) == "~/") then
    path = home .. string.sub(path, 2)
  end
  return path == "/" and path or string.gsub(path, "/+$", "")
end

local function open_project(cx, path, label)
  local target
  for _, row in sessions(cx) do
    if row.name == label then target = row.id; break end
  end
  if target then
    cx.sessions:switch(target)
    local tabs = {}
    for _, session in cx.session:sessions() do
      if session.id == target then
        for _, tab in session.tabs do tabs[tab] = true end
        break
      end
    end
    for _, pane in cx.session:panes() do
      if tabs[pane.tab] and pane.cwd and project_path(pane.cwd) == path then
        cx.layout:focus(pane.pane)
        return
      end
    end
    local pane = cx.layout:new_tab({ cwd = path })
    local tab = pane and cx.session:tab_of(pane)
    if tab then cx.layout:name_tab(tab, string.match(path, "([^/]+)$") or path) end
  else
    cx.sessions:create({ name = label, cwd = path })
    local pane = cx.session:focused()
    local tab = pane and cx.session:tab_of(pane)
    if tab then cx.layout:name_tab(tab, string.match(path, "([^/]+)$") or path) end
  end
end

command("projects", "Open project space", "s", function(cx)
  local host = cx.hosts:current()
  local dotfiles = project_path("~/.dotfiles")
  local function show(output, fresh, query)
    if fresh.hosts:current().id ~= host.id then
      fresh:toast("error", "Host changed; reopen Projects")
      return
    end
    local items, seen, roots = {}, {}, {}
    for _, row in sessions(fresh) do
      if row.name ~= "dotfiles" and row.name ~= ".dotfiles" then
        table.insert(items, { label = row.name, group = "Open spaces", session = row.id, current = row.current })
      end
    end
    for line in string.gmatch(output, "[^\r\n]+") do
      local name, path = string.match(line, "^([^\t]+)\t(.+)$")
      if name then table.insert(roots, { name = name, path = project_path(path) }) end
    end
    for line in string.gmatch(output, "[^\r\n]+") do
      local label, path = string.match(line, "^([^\t]+)\t(.+)$")
      path = project_path(path or line)
      local folder = string.match(path, "([^/]+)$") or path
      -- Keep the dotfiles choice canonical even when history contains worktrees.
      if folder == "dotfiles" or folder == ".dotfiles" then
        path, label = dotfiles, "dotfiles"
      end
      label = label or folder
      local session_name = label
      for _, root in roots do
        if path == root.path or string.sub(path, 1, #root.path + 1) == root.path .. "/" then
          session_name = root.name
          break
        end
      end
      if not seen[path] then
        seen[path] = true
        table.insert(items, { label = label, detail = path, group = "Projects", path = path, session_name = session_name })
      end
    end
    if query and query ~= "" then
      local matches = {}
      for _, item in items do
        local text = string.lower(item.label .. " " .. (item.detail or ""))
        local match = true
        for word in string.gmatch(string.lower(query), "%S+") do
          if not string.find(text, word, 1, true) then match = false; break end
        end
        if match then table.insert(matches, item) end
      end
      items = matches
    end
    -- Tern 0.9.2 caps pickers at 200 items; refine before handing it the list.
    if #items > 200 then
      while #items > 199 do table.remove(items) end
      table.insert(items, 1, { label = "Search all projects…", group = "Search", search = true })
    elseif #items == 0 then
      table.insert(items, { label = "No matches — search again…", search = true })
    end
    fresh:pick({ items = items, placeholder = "Project space", action = "open / focus" }):next(function(item, err, picked)
      if err then picked:toast("error", "Could not choose project", err); return end
      if not item then return end
      if picked.hosts:current().id ~= host.id then
        picked:toast("error", "Host changed; reopen Projects")
        return
      end
      if item.search then
        picked:prompt({ placeholder = "Project name or path", value = query or "" }):next(function(text, prompt_err, prompted)
          if prompt_err then prompted:toast("error", "Could not search projects", prompt_err); return end
          if text then show(output, prompted, text) end
        end)
      elseif item.session then
        for _, row in sessions(picked) do
          if row.id == item.session then picked.sessions:switch(row.id); return end
        end
        picked:toast("error", "That space has closed; reopen Projects")
      else
        open_project(picked, item.path, item.session_name)
      end
    end)
  end
  if host.kind == "remote" then show("", cx); return end
  tern.process.run({ "/opt/homebrew/bin/bash", tern.plugin.dir .. "/projects.sh" }, function(result, fresh)
    if result.status ~= 0 then
      fresh:toast("error", "Could not list projects", result.stderr)
      return
    end
    show(result.stdout, fresh)
  end)
end)

-- Tern has no session-modal terminal popups; launch in a disposable tab instead.
local launchers = {
  { "files", "Open files (Yazi)", "/", "yazi" },
  { "containers", "Manage containers (Lazydocker)", "i", "lazydocker" },
  { "tuxedo", "Open Tuxedo", "t", "tuxedo" },
  { "replace", "Search and replace (Serpl)", "shift+r", "serpl" },
  { "review", "Open Tuicr", "ctrl+r", "tuicr" },
  { "github", "Open GitHub dashboard", "g", "gh dash" },
  { "notes", "Open notes", "n", "~/.dotfiles/terminals/notes/note.sh" },
  { "playzones", "Open playzones", "p", "~/.dotfiles/terminals/playzones/playzone-picker.sh" },
}
for _, launcher in launchers do
  command(launcher[1], launcher[2], launcher[3], function(cx)
    local focused = cx.session:focused()
    local info = focused and cx.session:pane(focused)
    local pane = cx.layout:new_tab({ cwd = info and info.cwd, command = launcher[4] })
    local tab = pane and cx.session:tab_of(pane)
    if tab then cx.layout:name_tab(tab, launcher[2]) end
  end)
end
if tern.runtime.os == "macos" then
  command("appearance", "Toggle macOS appearance", "shift+t", function(cx)
    local home = tern.getenv("HOME")
    if not home then error("HOME is not set") end
    tern.process.run({ home .. "/.dotfiles/terminals/herdr/scripts/toggle-appearance.sh" }, function(result, fresh)
      if result.status ~= 0 then fresh:toast("error", "Could not toggle macOS appearance", result.stderr) end
    end)
  end)
end
