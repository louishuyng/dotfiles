-- Tabs module - tabline.wez with minimal transparent design
local wezterm = require("wezterm")
local theme = require("theme")

local Tabs = {}

local process_icons = {
	["nvim"] = { wezterm.nerdfonts.custom_neovim },
	["vim"] = { wezterm.nerdfonts.custom_vim },
	["fish"] = { wezterm.nerdfonts.md_fish },
	["zsh"] = { wezterm.nerdfonts.dev_terminal },
	["bash"] = { wezterm.nerdfonts.cod_terminal_bash },
	["node"] = { wezterm.nerdfonts.md_nodejs },
	["python"] = { wezterm.nerdfonts.dev_python },
	["python3"] = { wezterm.nerdfonts.dev_python },
	["ruby"] = { wezterm.nerdfonts.dev_ruby },
	["go"] = { wezterm.nerdfonts.md_language_go },
	["cargo"] = { wezterm.nerdfonts.dev_rust },
	["rustc"] = { wezterm.nerdfonts.dev_rust },
	["git"] = { wezterm.nerdfonts.dev_git },
	["lazygit"] = { wezterm.nerdfonts.dev_git },
	["docker"] = { wezterm.nerdfonts.dev_docker },
	["kubectl"] = { wezterm.nerdfonts.md_kubernetes },
	["ssh"] = { wezterm.nerdfonts.md_ssh },
	["make"] = { wezterm.nerdfonts.seti_makefile },
	["brew"] = { wezterm.nerdfonts.dev_homebrew },
	["npm"] = { wezterm.nerdfonts.dev_npm },
}

local function build_theme()
	local c = theme.get_palette()
	local bg = "NONE"
	local active = c.crust

	return {
		normal_mode = {
			a = { fg = c.yellow, bg = bg },
			b = { fg = c.text, bg = bg },
			c = { fg = c.overlay1, bg = bg },
			x = { fg = c.red, bg = bg },
			y = { fg = c.green, bg = bg },
			z = { fg = c.blue, bg = bg },
		},
		copy_mode = {
			a = { fg = c.yellow, bg = bg },
			b = { fg = c.text, bg = bg },
			c = { fg = c.overlay1, bg = bg },
			x = { fg = c.red, bg = bg },
			y = { fg = c.green, bg = bg },
			z = { fg = c.blue, bg = bg },
		},
		search_mode = {
			a = { fg = c.yellow, bg = bg },
			b = { fg = c.text, bg = bg },
			c = { fg = c.overlay1, bg = bg },
			x = { fg = c.overlay1, bg = bg },
			y = { fg = c.teal, bg = bg },
			z = { fg = c.blue, bg = bg },
		},
		tab = {
			active = { fg = c.green, bg = active },
			inactive = { fg = c.subtext1, bg = bg },
			inactive_hover = { fg = c.text, bg = bg },
		},
	}
end

function Tabs.setup(config, tabline)
	tabline.setup({
		options = {
			theme = config.colors or "Catppuccin Mocha",
			theme_overrides = build_theme(),
			section_separators = { left = "", right = "" },
			component_separators = { left = "", right = "" },
			tab_separators = { left = "", right = "" },
		},
		sections = {
			tabline_a = { { "workspace", icon = "Louis 󱘖" } },
			tabline_b = {},
			tabline_c = {},
			tab_active = {
				{ "index", padding = { left = 1, right = 0 } },
				{ "cwd", padding = { left = 1, right = 0 }, max_length = 20 },
				{
					"process",
					icons_only = true,
					padding = { left = 1, right = 0 },
					process_to_icon = process_icons,
				},
			},
			tab_inactive = {
				{ "index", padding = { left = 1, right = 0 } },
				{ "cwd", padding = { left = 1, right = 0 }, max_length = 16 },
				{
					"process",
					icons_only = true,
					padding = { left = 1, right = 1 },
					process_to_icon = process_icons,
				},
			},
			tabline_x = {
				{ "cpu", throttle = 3 },
			},
			tabline_y = {
				{ "ram", throttle = 3 },
			},
			tabline_z = { "domain" },
		},
	})

	tabline.apply_to_config(config)

	config.use_fancy_tab_bar = true
	config.tab_bar_at_bottom = true
end

return Tabs
