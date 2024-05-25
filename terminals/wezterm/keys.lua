local wezterm = require("wezterm")

local direction_keys = { h = "Left", j = "Down", k = "Up", l = "Right" }

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == "resize" and "SHIFT|ALT" or "LEADER",
    action = wezterm.action_callback(function(win, pane)
      if resize_or_move == "resize" then
        win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
      else
        win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
      end
    end)
  }
end

local Keys = {}

function Keys.setup(config)
  -- config.disable_default_key_bindings = true
  -- config.leader = {key = 'a', mods = 'CTRL', timeout_milliseconds = 1000}
  -- config.keys = {
  --   split_nav("move", "h"), split_nav("move", "j"), split_nav("move", "k"),
  --   split_nav("move", "l"), split_nav("resize", "h"), split_nav("resize", "j"),
  --   split_nav("resize", "k"), split_nav("resize", "l"), {
  --     mods = "LEADER|SHIFT",
  --     key = [[|]],
  --     action = wezterm.action.SplitPane({
  --       top_level = true,
  --       direction = "Right",
  --       size = {Percent = 50}
  --     })
  --   }, {
  --     mods = "LEADER",
  --     key = [[-]],
  --     action = wezterm.action.SplitPane {
  --       direction = 'Down',
  --       size = {Percent = 25}
  --     }
  --   }, {key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen},
  --   {
  --     key = "w",
  --     mods = "CMD",
  --     action = wezterm.action({CloseCurrentTab = {confirm = false}})
  --   },
  --   {key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState},
  --   {key = "D", mods = "CMD", action = wezterm.action.ShowDebugOverlay},
  --   {key = "1", mods = "CMD", action = wezterm.action({ActivateTab = 0})},
  --   {key = "2", mods = "CMD", action = wezterm.action({ActivateTab = 1})},
  --   {key = "3", mods = "CMD", action = wezterm.action({ActivateTab = 2})},
  --   {key = "4", mods = "CMD", action = wezterm.action({ActivateTab = 3})},
  --   {key = "5", mods = "CMD", action = wezterm.action({ActivateTab = 4})},
  --   {key = "6", mods = "CMD", action = wezterm.action({ActivateTab = 5})},
  --   {key = "7", mods = "CMD", action = wezterm.action({ActivateTab = 6})},
  --   {key = "8", mods = "CMD", action = wezterm.action({ActivateTab = 7})},
  --   {key = "9", mods = "CMD", action = wezterm.action({ActivateTab = 8})},
  --   {
  --     key = "[",
  --     mods = "CMD",
  --     action = wezterm.action({ActivateTabRelative = -1})
  --   },
  --   {
  --     key = "]",
  --     mods = "CMD",
  --     action = wezterm.action({ActivateTabRelative = 1})
  --   }, {key = "{", mods = "CMD", action = wezterm.action.MoveTabRelative(-1)},
  --   {key = "}", mods = "CMD", action = wezterm.action.MoveTabRelative(1)},
  --   {key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize},
  --   {key = "=", mods = "CMD", action = wezterm.action.IncreaseFontSize},
  --   {key = "0", mods = "CMD", action = wezterm.action.ResetFontSize},
  --   {key = "c", mods = "CMD", action = wezterm.action({CopyTo = "Clipboard"})},
  --   {
  --     key = "v",
  --     mods = "CMD",
  --     action = wezterm.action({PasteFrom = "Clipboard"})
  --   }, {
  --     key = "t",
  --     mods = "CMD",
  --     action = wezterm.action({SpawnTab = "CurrentPaneDomain"})
  --   }, {
  --     key = "f",
  --     mods = "CMD",
  --     action = wezterm.action({Search = {CaseInSensitiveString = ""}})
  --   }, {key = 'q', mods = 'CMD', action = wezterm.action.QuitApplication}
  -- }
end

return Keys
