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

-- Incremental selection
_G.selected_nodes = {}

local function get_node_at_cursor()
  local node = vim.treesitter.get_node()
  if not node then return nil end
  return node
end

local function select_node(node)
  if not node then return end
  local start_row, start_col, end_row, end_col = node:range()
  vim.fn.setpos("'<", { 0, start_row + 1, start_col + 1, 0 })
  vim.fn.setpos("'>", { 0, end_row + 1, end_col, 0 })
  vim.cmd('normal! gv')
end

vim.keymap.set({ "n" }, "<tab>", function()
  _G.selected_nodes = {}

  local current_node = get_node_at_cursor()
  if not current_node then return end

  table.insert(_G.selected_nodes, current_node)
  select_node(current_node)
end, { desc = "Select treesitter node" })


vim.keymap.set("v", "<tab>", function()
  if #_G.selected_nodes == 0 then
    return
  end

  local current_node = _G.selected_nodes[#_G.selected_nodes]

  if not current_node then return end

  local parent = current_node:parent()
  if parent then
    table.insert(_G.selected_nodes, parent)
    select_node(parent)
  end
end, { desc = "Increment selection" })

vim.keymap.set("v", "<S-tab>", function()
  table.remove(_G.selected_nodes)
  local current_node = _G.selected_nodes[#_G.selected_nodes]
  if current_node then
    select_node(current_node)
  end
end, { desc = "Decrement selection" })
