local wezterm = require 'wezterm'

local Tabs = {}

local function string_rfind(s, t, rstart)
  rstart = rstart or #s
  for i = rstart, 1, -1 do
    local match = true
    for j = 1, #t do
      if i + j - 1 > #s then
        match = false
        break
      end
      local a = string.byte(s, i + j - 1)
      local b = string.byte(t, j)
      if a ~= b then
        match = false
        break
      end
    end
    if match then return i end
  end
  return nil
end

function Tabs.setup()
  local function tab_title(tab_info, max_width)
    local tab_index = tab_info.tab_index
    local title = tab_info.tab_title
    local result = (title and #title > 0) and title or
        tab_info.active_pane.title
    local last_slash_pos = string_rfind(result, "/")
    last_slash_pos = last_slash_pos or string_rfind(result, "\\")
    if last_slash_pos then result = result:sub(last_slash_pos + 1) end
    result = string.format("%d %s", tab_index + 1,
      wezterm.truncate_left(result, max_width))
    return result
  end

  wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
    local title = tab_title(tab, max_width)

    title = " " .. title .. " "

    return { { Text = title } }
  end)
end

return Tabs
