local present1, lspconfig = pcall(require, "lspconfig")
local present2, lspinstall = pcall(require, "lspinstall")
if not (present1 or present2) then
    return
end

local protocol = require('vim.lsp.protocol')

require("null-ls").config {}
require("lspconfig")["null-ls"].setup {}

local function on_attach(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    protocol.CompletionItemKind = {
      '';   -- Text          = 1;
      '';   -- Method        = 2;
      'ƒ';   -- Function      = 3;
      '';   -- Constructor   = 4;
      '識';  -- Field         = 5;
      '';   -- Variable      = 6;
      '';   -- Class         = 7;
      'ﰮ';   -- Interface     = 8;
      '';   -- Module        = 9;
      '';   -- Property      = 10;
      '';   -- Unit          = 11;
      '';   -- Value         = 12;
      '了';  -- Enum          = 13;
      '';   -- Keyword       = 14;
      '﬌';   -- Snippet       = 15;
      '';   -- Color         = 16;
      '';   -- File          = 17;
      '渚';  -- Reference     = 18;
      '';   -- Folder        = 19;
      '';   -- EnumMember    = 20;
      '';   -- Constant      = 21;
      '';   -- Struct        = 22;
      '鬒';  -- Event         = 23;
      'Ψ';   -- Operator      = 24;
      '';   -- TypeParameter = 25;
    }

    local ts_utils = require("nvim-lsp-ts-utils")
    ts_utils.setup {
      -- update imports on file move
      update_imports_on_move = true,
      require_confirmation_on_move = false,
      watch_dir = nil,

     -- eslint
      eslint_enable_disable_comments = true,
      eslint_enable_code_actions = true,
      eslint_bin = "eslint",
      eslint_enable_diagnostics = true,
      eslint_opts = {},

      -- formatting
      enable_formatting = false,
      formatter = "prettier",
      formatter_opts = {},
    }

    local opts = {noremap = true, silent = true}

    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    -- Mappings.
    buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap("n", "gf", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    buf_set_keymap('n', ',rr', "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'ac', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap("n", ",rf", ":TSLspRenameFile<CR>", opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true


-- lspInstall + lspconfig stuff

local function setup_servers()
    lspinstall.setup()
    local servers = lspinstall.installed_servers()

    for _, lang in pairs(servers) do
        if lang == "lua" then
            lspconfig[lang].setup {
                root_dir = vim.loop.cwd,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = {"vim"}
                        },
                        workspace = {
                            library = {
                                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                                [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
                            },
                            maxPreload = 100000,
                            preloadFileSize = 10000
                        },
                        telemetry = {
                            enable = false
                        }
                    }
                }
            }
        else
            lspconfig[lang].setup {
                on_attach = on_attach,
                capabilities = capabilities,
                root_dir = vim.loop.cwd
            }
        end
    end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
lspinstall.post_install_hook = function()
    setup_servers() -- reload installed servers
    vim.cmd("bufdo e") -- triggers FileType autocmd that starts the server
end

-- replace the default lsp diagnostic symbols
function lspSymbol(name, icon)
    vim.fn.sign_define("LspDiagnosticsSign" .. name, {text = icon, numhl = "LspDiagnosticsDefaul" .. name})
end

lspSymbol("Error", "")
lspSymbol("Warning", "")
lspSymbol("Information", "")
lspSymbol("Hint", "")

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        virtual_text = {
            prefix = "",
            spacing = 0
        },
        signs = true,
        underline = true,
        -- set this to true if you want diagnostics to show in insert mode
        update_in_insert = false
    }
)
