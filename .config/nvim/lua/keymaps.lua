-- Keymaps

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- keymap('n', ';', ':', { noremap = true })

-- Better navigation for wrapped lines.
keymap('n', 'j', 'gj', opts)
keymap('n', 'k', 'gk', opts)
keymap('n', '<down>', 'gj', opts)
keymap('i', '<down>', '<c-o>gj', opts)
keymap('n', '<up>', 'gk', opts)
keymap('i', '<up>', '<c-o>gk', opts)

-- q remapped to Q to avoid accidental macro mode
keymap('n', 'Q', 'q', opts)
keymap('n', 'q', '<Nop>', opts)

-- Command mode up/down remap
keymap('c', '<C-k>', function()
  return '<Up>'
end, { expr = true })
keymap('c', '<C-j>', function()
  return '<Down>'
end, { expr = true })

-- Next/Previous result
keymap('n', '<c-n>', ':cn<cr>', opts)
keymap('n', '<c-p>', ':cp<cr>', opts)

-- Tab navigation
keymap('n', '<c-j>', ':tabnext<cr>', opts)
keymap('n', '<c-k>', ':tabprev<cr>', opts)
keymap('i', '<c-j>', '<c-o>:tabnext<cr>', opts)
keymap('i', '<c-k>', '<c-o>:tabprev<cr>', opts)
keymap('n', '<c-l>', ':tabm +1<cr>', opts)
keymap('n', '<c-h>', ':tabm -1<cr>', opts)
keymap('n', 'gd', ':tabclose<cr>', opts)
keymap('n', 'ga', ':tabnew<cr>', opts)
keymap('n', 'gs', ':tab split<cr>', opts)
keymap('n', 'go', ':tabonly<cr>', opts)

-- Terminal escape

keymap('t', '<esc>', '<c-\\><c-n>', opts)

keymap({ 'n', 'x', 'o' }, '<tab>', function()
  require('flash').treesitter({
    actions = {
      ['<tab>'] = 'next',
      ['<s-tab>'] = 'prev',
    },
  })
end, { desc = 'Treesitter incremental selection' })
