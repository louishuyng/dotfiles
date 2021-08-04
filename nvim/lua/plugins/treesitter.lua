local present, ts_config = pcall(require, "nvim-treesitter.configs")
if not present then
    return
end

ts_config.setup {
    ensure_installed = {
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "bash",
        "lua",
        "json",
        "ruby",
        "bash",
        "regex",
        -- "python"
        -- "rust",
        -- "go"
    },
    highlight = {
        enable = true,
        use_languagetree = true
    }
}
