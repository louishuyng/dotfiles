local opt = { silent = true, noremap = true }

-- General
vim.keymap.set('n', ',s', ':<C-u>split<CR>', { silent = true, noremap = true, desc = 'V Split buffer' })
vim.keymap.set('n', ',v', ':<C-u>vsplit<CR>', { silent = true, noremap = true, desc = 'H Split buffer' })

vim.keymap.set('v', '<C-x>', ':!pbcopy<CR>', opt)
vim.keymap.set('v', '<C-c>', ':w !pbcopy<CR><CR>', opt)

vim.keymap.set('v', '/', '*')
vim.keymap.set('n', '<C-j>', '<C-w>j', opt)
vim.keymap.set('n', '<C-k>', '<C-w>k', opt)
vim.keymap.set('n', '<C-l>', '<C-w>l', opt)
vim.keymap.set('n', '<C-h>', '<C-w>h', opt)

-- Custom resize mode: press <leader>rs then use hjkl to resize continuously
vim.keymap.set('n', '<leader>rs', function()
  vim.notify('Resize Mode: h/j/k/l to resize, ESC/q to exit', vim.log.levels.INFO)
  local chars = { 'h', 'j', 'k', 'l' }
  local exit_chars = { 'q', '\27' } -- q and ESC (\27)
  while true do
    vim.cmd('redraw')
    local ok, char = pcall(vim.fn.getcharstr)
    if not ok then
      vim.notify('Exited resize mode', vim.log.levels.INFO)
      break
    end

    -- Check if user wants to exit
    if vim.tbl_contains(exit_chars, char) then
      vim.notify('Exited resize mode', vim.log.levels.INFO)
      break
    end

    -- Handle resize keys
    if vim.tbl_contains(chars, char) then
      if char == 'h' then
        require('smart-splits').resize_left(5)
      elseif char == 'j' then
        require('smart-splits').resize_down(5)
      elseif char == 'k' then
        require('smart-splits').resize_up(5)
      elseif char == 'l' then
        require('smart-splits').resize_right(5)
      end
    else
      -- Any other key exits and feeds the key back
      if char ~= '' then
        vim.api.nvim_feedkeys(char, 'n', false)
      end
      vim.notify('Exited resize mode', vim.log.levels.INFO)
      break
    end
  end
end, { desc = 'Enter resize mode (use hjkl, ESC/q to exit)' })

-- Faster Save and Quit
vim.keymap.set('n', '<leader>w', ':silent w!<CR>', opt)
vim.keymap.set('n', '<leader>W', ':silent wa!<CR>', opt)
vim.keymap.set('n', '<leader>q', ':q!<CR>', opt)

-- Scrolling Center
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", opt)
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", opt)

-- Macro Apply Visual
vim.keymap.set('v', ',m', ':normal @', { desc = 'Apply macro' })

-- Move Block
vim.keymap.set('v', '<S-j>', ":m'>+<CR>gv=gv", opt)
vim.keymap.set('v', '<S-k>', ':m-2<CR>gv=gv', opt)

-- Sorting
vim.keymap.set('v', '<leader>so', ':sort<CR>', { silent = true, noremap = true, desc = 'Sorting' })

-- Open URL
vim.keymap.set(
  'n',
  '<leader>ou',
  ':call OpenUrlUnderCursor()<CR>',
  { silent = true, noremap = true, desc = 'Open url under cursor' }
)

-- Yank
-- " replace currently selected text with default register
-- " without yanking it
vim.keymap.set('v', 'p', '"_dP', opt)

-- Replace
vim.keymap.set('n', ';r', 'yiw:%s/<C-R>"/', opt)
vim.keymap.set('v', ';r', '"_y:%s/<C-R>"/', opt)

-- Lazy
vim.keymap.set('n', '<leader>li', ':Lazy install<CR>', opt)
vim.keymap.set('n', '<leader>lc', ':Lazy clean<CR>', opt)
vim.keymap.set('n', '<leader>lu', ':Lazy update<CR>', opt)

-- Register
local esc = vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
vim.fn.setreg('l', "yoconsole.log('" .. esc .. 'pa:' .. esc .. 'la, ' .. esc .. 'pl')

-- Noice
vim.keymap.set('n', '<leader>mo', ':Noice all<CR>', { desc = 'Log vim messages', silent = true, noremap = true })

-- Reload Buffer
vim.keymap.set('n', '<leader>rb', function()
  -- Reload the current buffer lsp and enable copilot
  vim.cmd('edit!')
  vim.cmd('LspRestart')
  vim.cmd('Copilot enable')
  vim.notify('Buffer reloaded', vim.log.levels.INFO)
end, { desc = 'Reload buffer', silent = true, noremap = true })
