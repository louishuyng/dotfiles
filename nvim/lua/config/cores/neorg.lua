local present, neorg = pcall(require, "neorg")

if not present then
   return
end

neorg.setup {
  load = {
    ["core.defaults"] = {},
    ["core.gtd.base"] = {
      config = {
        workspace = "work"
      }
    },
    ["core.norg.dirman"] = {
      config = {
        workspaces = {
          work = "~/Dev/org/work",
          life = "~/Dev/org/life",
        }
      }
    },
    ["core.integrations.telescope"] = {},
    ["core.keybinds"] = {
      config = {
          hook = function(keybinds)
             keybinds.unmap("norg", "n", "<C-s>")
             keybinds.map_event_to_mode("norg", {
                n = { -- Bind keys in normal mode
                    { "<leader>fl", "core.integrations.telescope.find_linkable" },
                },
              }, {
                silent = true,
                noremap = true,
              })
          end,
      }
    }
  }
}
