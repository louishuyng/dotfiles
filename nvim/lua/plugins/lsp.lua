return {
  { 'williamboman/mason.nvim', cmd = 'Mason', build = ':MasonUpdate' },
  { 'stevearc/conform.nvim', event = { 'BufWritePre' }, cmd = { 'ConformInfo' } },
  {
    'stevearc/aerial.nvim',
    cmd = { 'AerialToggle', 'AerialOpen', 'AerialInfo' },
    opts = {},
  },
}
