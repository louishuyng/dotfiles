return {
  {"nvim-telescope/telescope.nvim", cmd = "Telescope"}, {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
  }, {"ThePrimeagen/harpoon"}, {'kyazdani42/nvim-tree.lua', tag = 'nightly'},
  {"folke/trouble.nvim", config = function() require "config.libs.trouble" end},
  {"folke/todo-comments.nvim"}, {'LinArcX/telescope-env.nvim'}
}
