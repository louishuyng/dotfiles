local present, neorg = pcall(require, "neorg")

if not present then
   return
end

neorg.setup {
  load = {
    ["core.defaults"] = {},
    ["core.norg.concealer"] = {
      config = {
        icon_preset = "diamond"
      }
    },
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
   -- Keys for managing GTD
              { "<leader>tc", "core.gtd.base.capture" },
              { "<leader>tv", "core.gtd.base.views" },
              { "<leader>te", "core.gtd.base.edit" },

              -- Keys for managing notes
              { "<leader>nn", "core.norg.dirman.new.note" },

              -- mnemonic: markup toggle
              { "<leader>mt", "core.norg.concealer.toggle-markup" },
            },
          }, {
            silent = true,
            noremap = true,
          })
        end,
      }
    },
    ["core.presenter"] = {
      config = {
        zen_mode = "zen-mode",
      }
    },
  }
}
