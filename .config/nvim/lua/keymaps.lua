-- Keymaps

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap('n', ';', ':', { noremap = true })

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
keymap('c', '<c-k>', '<up>', opts)
keymap('c', '<c-j>', '<down>', opts)

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

keymap('n', '<c-left>', '<c-w>h', opts)
keymap('n', '<c-down>', '<c-w>j', opts)
keymap('n', '<c-up>', '<c-w>k', opts)
keymap('n', '<c-right>', '<c-w>l', opts)

local function search_with_two_chars(search_command)
  return function()
    local char1 = vim.fn.getchar()
    local char2 = vim.fn.getchar()

    char1 = vim.fn.nr2char(char1)
    char2 = vim.fn.nr2char(char2)

    local search_term = char1 .. char2
    vim.api.nvim_feedkeys(search_command .. search_term .. "\n:noh\n", "n", false)
  end
end

vim.api.nvim_set_keymap('n', 's', '', { noremap = true, silent = true, callback = search_with_two_chars('/') })
vim.api.nvim_set_keymap('x', 's', '', { noremap = true, silent = true, callback = search_with_two_chars('/') })
vim.api.nvim_set_keymap('n', 'S', '', { noremap = true, silent = true, callback = search_with_two_chars('?') })
vim.api.nvim_set_keymap('x', 'S', '', { noremap = true, silent = true, callback = search_with_two_chars('?') })
