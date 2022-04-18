vim.cmd [[ 
  sign define DiagnosticSignError text= linehl= texthl=DiagnosticSignError numhl= 
  sign define DiagnosticSignWarn text= linehl= texthl=DiagnosticSignWarn numhl= 
  sign define DiagnosticSignInfo text= linehl= texthl=DiagnosticSignInfo numhl= 
  sign define DiagnosticSignHint text=💡 linehl= texthl=DiagnosticSignHint numhl= 
]]

-- require('lsp/deno')
require "config/lsp/angular"
require "config/lsp/bash"
require "config/lsp/css"
require "config/lsp/dart"
require "config/lsp/golang"
require "config/lsp/json"
require "config/lsp/lua"
require "config/lsp/null_ls"
require "config/lsp/ruby"
require "config/lsp/rust"
require "config/lsp/sql"
require "config/lsp/typescript"
require "config/lsp/vim"
