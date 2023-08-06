-- Keymaps

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better navigation for wrapped lines.
keymap('n', 'j', 'gj', opts)
keymap('n', 'k', 'gk', opts)
keymap('n', '<down>', 'gj', opts)
keymap('i', '<down>', '<c-o>gj', opts)
keymap('n', '<up>', 'gk', opts)
keymap('i', '<up>', '<c-o>gk', opts)

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

-- Sort
keymap('n', 'gh', ':Sort<cr>', opts)
keymap('v', 'gh', '<esc>:Sort<cr>', opts)

local function on_list(options)
  vim.fn.setqflist({}, ' ', options)
  vim.api.nvim_command('cfirst')
end

keymap('n', '<leader>e', vim.diagnostic.open_float, opts)
keymap('n', '<leader>ak', vim.diagnostic.goto_prev, opts)
keymap('n', '<leader>ap', function()
  vim.diagnostic.goto_prev({
    severity = vim.diagnostic.severity.ERROR,
  })
end, opts)
keymap('n', '<leader>aj', vim.diagnostic.goto_next, opts)
keymap('n', '<leader>an', function()
  vim.diagnostic.goto_next({
    severity = vim.diagnostic.severity.ERROR,
  })
end, opts)

-- Telescope

keymap('n', '<leader>g', function()
  local text = vim.fn.expand("<cword>")
  vim.fn.histadd(':', 'gr ' .. text)
  vim.cmd('silent gr ' .. text)
end, opts)

keymap('t', '<esc>', '<c-\\><c-n>', opts)

-- Leader config

keymap('n', '<leader>l', ':Lazy<cr>', opts)

keymap('n', '<leader>n', ':silent noh<cr>', opts)
keymap('n', '<leader>q', ':qa<cr>', opts)

keymap('n', '<leader>pp', ":let @+ = expand('%')<cr>", opts)
keymap('n', '<leader>pn', ":let @+ = expand('%:t')<cr>", opts)
keymap('n', '<leader>pf', ":let @+ = expand('%:p')<cr>", opts)

keymap('n', '<leader>s', ':w<cr>', opts)

-- window commands

keymap('n', '<leader>ww', '<c-w>w', opts)
keymap('n', '<leader>wc', '<c-w>c', opts)
keymap('n', '<leader>wo', '<c-w>o', opts)
keymap('n', '<leader>wh', '<c-w>h', opts)
keymap('n', '<leader>wj', '<c-w>j', opts)
keymap('n', '<leader>wk', '<c-w>k', opts)
keymap('n', '<leader>wl', '<c-w>l', opts)

keymap('n', '<c-left>', '<c-w>h', opts)
keymap('n', '<c-down>', '<c-w>j', opts)
keymap('n', '<c-up>', '<c-w>k', opts)
keymap('n', '<c-right>', '<c-w>l', opts)

-- LSP

keymap('n', '<leader>ad', function() vim.lsp.buf.declaration { on_list = on_list } end, opts)
-- keymap('n', '<leader>d', function() vim.lsp.buf.definition{on_list=on_list} end, opts)
-- Mapping to c-] because LSP go to definition then works with c-t
keymap('n', '<leader>d', '<c-]>', opts)
keymap('n', '<leader>k', vim.lsp.buf.hover, opts)

keymap('n', '<leader>at', function() vim.lsp.buf.type_definition { on_list = on_list } end, opts)
keymap('n', '<leader>ar', vim.lsp.buf.rename, opts)
keymap('n', '<leader>ac', vim.lsp.buf.code_action, opts)
keymap('v', '<leader>ac', vim.lsp.buf.code_action, opts)
keymap('n', '<leader>af', function() vim.lsp.buf.references(nil, { on_list = on_list }) end, opts)

-- vimrc file
keymap('n', '<leader>v', ':e ~/.config/nvim/lua/init.lua<cr>', opts)
keymap('n', '<leader>V', ':source $MYVIMRC<cr>', opts)
