local present, neorg = pcall(require, "neorg")
if not present then return end

neorg.setup({
  load = {
    ["core.defaults"] = {},
    ["core.highlights"] = {
      config = {
        highlights = {
          headings = {["1"] = {title = "+TSTitle", prefix = "+TSTitle"}},
          quotes = {["1"] = {prefix = "+Grey", content = "+Grey"}}
        }
      }
    },
    ["core.norg.concealer"] = {
      config = {
        icon_preset = "diamond",
        markup_preset = "dimmed",
        dim_code_blocks = {enabled = false}
      }
    },
    ["core.gtd.base"] = {config = {workspace = "work"}},
    ["core.norg.dirman"] = {
      config = {workspaces = {work = "~/Dev/org/work", life = "~/Dev/org/life"}}
    },
    ["core.keybinds"] = {
      config = {
        hook = function(keybinds)
          keybinds.unmap("norg", "n", "<C-s>")

          -- gtd
          keybinds.map_event_to_mode("norg", {
            n = { -- Bind keys in normal mode
              -- Keys for managing notes
              {"<leader>oc", "core.gtd.base.capture"},
              {"<leader>ov", "core.gtd.base.views"},
              {"<leader>oe", "core.gtd.base.edit"}
            }
          }, {silent = true, noremap = true})
        end
      }
    },
    ["core.export.markdown"] = {config = {extensions = "all"}},
    ["core.norg.journal"] = {}
  }
})
