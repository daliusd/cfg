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

local function on_list(options)
  vim.fn.setqflist({}, ' ', options)
  vim.api.nvim_command('cfirst')
end

keymap('n', '<leader>e', vim.diagnostic.open_float, opts)
keymap('n', '<leader>ak', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
keymap('n', '<leader>ap', function()
  vim.diagnostic.jump({
    count = -1,
    float = true,
    severity = vim.diagnostic.severity.ERROR,
  })
end, opts)
keymap('n', '<leader>aj', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
keymap('n', '<leader>an', function()
  vim.diagnostic.jump({
    count = 1,
    float = true,
    severity = vim.diagnostic.severity.ERROR,
  })
end, opts)

-- Grep

keymap('n', '<leader>g', function()
  local text = vim.fn.expand("<cword>")
  vim.fn.histadd(':', 'gr ' .. text)
  vim.cmd('silent gr ' .. text)
end, opts)

-- Terminal escape

keymap('t', '<esc>', '<c-\\><c-n>', opts)

-- Leader config

keymap('n', '<leader>l', ':Lazy<cr>', opts)

keymap('n', '<leader>n', ':silent noh<cr>', opts)
keymap('n', '<leader>q', ':qa<cr>', opts)

keymap('n', '<leader>p', ":let @+ = expand('%:p')<cr>", opts)
keymap('n', '<leader>o', ":let @+ = expand('%:t')<cr>", opts)

keymap('n', '<leader>s', ':w<cr>', opts)

keymap('n', '<leader>b',
  function()
    require "gitlinker".get_repo_url({
      action_callback = function(url)
        local commit = vim.fn.expand("<cword>")
        require "gitlinker.actions".open_in_browser(url .. '/commit/' .. commit)
      end
    })
  end,
  opts)
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
keymap('n', '<leader>m', vim.lsp.buf.code_action, opts)
keymap('v', '<leader>m', vim.lsp.buf.code_action, opts)
keymap('n', '<leader>af', function() vim.lsp.buf.references(nil, { on_list = on_list }) end, opts)
keymap('n', '<leader>/', function() vim.lsp.buf.references(nil, { on_list = on_list }) end, opts)

-- vimrc file
keymap('n', '<leader>v', ':e ~/.config/nvim/init.lua<cr>', opts)
keymap('n', '<leader>V', ':source $MYVIMRC<cr>', opts)

-- -- venn.nvim: enable or disable keymappings
-- function _G.Toggle_venn()
--   local venn_enabled = vim.inspect(vim.b.venn_enabled)
--   if venn_enabled == "nil" then
--     vim.b.venn_enabled = true
--     vim.cmd [[setlocal ve=all]]
--     -- draw a line on HJKL keystokes
--     vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", { noremap = true })
--     vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", { noremap = true })
--     vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", { noremap = true })
--     vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", { noremap = true })
--     -- draw a box by pressing "f" with visual selection
--     vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
--   else
--     vim.cmd [[setlocal ve=]]
--     vim.cmd [[mapclear <buffer>]]
--     vim.b.venn_enabled = nil
--   end
-- end
--
-- -- toggle keymappings for venn using <leader>j
-- vim.api.nvim_set_keymap('n', '<leader>j', ":lua Toggle_venn()<CR>", { noremap = true })

local function search_with_two_chars(search_command)
  return function()
    local char1 = vim.fn.getchar()
    local char2 = vim.fn.getchar()

    char1 = vim.fn.nr2char(char1)
    char2 = vim.fn.nr2char(char2)

    local search_term = char1 .. char2
    vim.api.nvim_feedkeys(search_command .. search_term .. "\n", "n", false)
  end
end

vim.api.nvim_set_keymap('n', 's', '', { noremap = true, silent = true, callback = search_with_two_chars('/') })
vim.api.nvim_set_keymap('v', 's', '', { noremap = true, silent = true, callback = search_with_two_chars('/') })
vim.api.nvim_set_keymap('n', 'S', '', { noremap = true, silent = true, callback = search_with_two_chars('?') })
vim.api.nvim_set_keymap('v', 'S', '', { noremap = true, silent = true, callback = search_with_two_chars('?') })
