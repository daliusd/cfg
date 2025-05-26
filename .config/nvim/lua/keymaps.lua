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

-- movement
vim.keymap.set({ 'n', 'v' }, '<C-up>', '<cmd>Treewalker Up<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-down>', '<cmd>Treewalker Down<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-left>', '<cmd>Treewalker Left<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-right>', '<cmd>Treewalker Right<cr>', { silent = true })

-- swapping
vim.keymap.set('n', '<C-S-up>', '<cmd>Treewalker SwapUp<cr>', { silent = true })
vim.keymap.set('n', '<C-S-down>', '<cmd>Treewalker SwapDown<cr>', { silent = true })
vim.keymap.set('n', '<C-S-left>', '<cmd>Treewalker SwapLeft<cr>', { silent = true })
vim.keymap.set('n', '<C-S-right>', '<cmd>Treewalker SwapRight<cr>', { silent = true })

local function search_with_two_chars(search_command)
  return function()
    local char1 = vim.fn.getchar()
    local char2 = vim.fn.getchar()

    char1 = vim.fn.nr2char(char1)
    char2 = vim.fn.nr2char(char2)

    local search_term = char1 .. char2

    vim.api.nvim_feedkeys(search_command .. search_term .. "\n", "n", false)

    vim.schedule(function()
      vim.cmd('nohlsearch')
    end)
  end
end

keymap('n', 's', search_with_two_chars('/'), opts)
keymap('x', 's', search_with_two_chars('/'), opts)
keymap('n', 'S', search_with_two_chars('?'), opts)
keymap('x', 'S', search_with_two_chars('?'), opts)


vim.keymap.set({ "n" }, "<cr>", function()
  local node = vim.treesitter.get_node()
  if not node then return end

  local start_row, start_col, end_row, end_col = node:range()
  vim.fn.setpos("'<", { 0, start_row + 1, start_col + 1, 0 })
  vim.fn.setpos("'>", { 0, end_row + 1, end_col, 0 })
  vim.cmd('normal! gv')
end, { desc = "Select treesitter node" })
