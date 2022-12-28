return {
  {
    "nvim-neorg/neorg",
    -- lazy-load on filetype
    ft = "norg",
    build = ":Neorg sync-parsers" -- This is the important bit!
  }
}
