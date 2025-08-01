-- UI part

vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true

vim.api.nvim_create_autocmd('FocusGained', {
  callback = function()
    if vim.o.buftype ~= 'cmdline' then
      vim.cmd('checktime')
    end
  end,
})

vim.opt.background = 'light'
vim.opt.hidden = true -- Allow opening new buffer without saving or opening it in new tab
vim.opt.showmode = false -- This is shown by status line plugin already so I don't need NORMAL/INSERT/... in command line

vim.opt.list = true
vim.opt.listchars = { trail = '.', tab = ':▷⋮' } -- Show trailing dots and tabs

vim.opt.scrolloff = 3 -- Keep 3 lines below and above the cursor
vim.opt.number = true -- Show line numbering
vim.opt.relativenumber = true -- Show relative numbering
vim.opt.numberwidth = 1 -- Use 1 col + 1 space for numbers

-- Vim stuff
vim.opt.fixeol = false -- Let's not fix end-of-line

vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.directory = '/tmp'
vim.opt.undofile = true
vim.opt.undodir = '/tmp'

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 300
vim.opt.completeopt = 'menu,menuone,noselect' -- nvim-cmp suggestion
vim.opt.signcolumn = 'yes' -- merge signcolumn and number column into one
vim.opt.showtabline = 2

vim.opt.diffopt:append('vertical') -- Vertical diff

-- We want string-like-this to be treated as word. That however means that proper spacing must
-- be used in arithmetic operations.
vim.opt.iskeyword:append('-')

-- Indentation and Tab
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.sw = 2 -- Spaces per indent

vim.opt.tabstop = 8 -- Number of spaces per tab. People usually use 4, but they shouldn't use tab in the first place.

vim.opt.foldmethod = 'indent'
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

vim.opt.foldlevelstart = 99

-- Encodings and spelling
vim.opt.fileencodings = 'utf-8,ucs-bom,latin1'
vim.opt.encoding = 'utf-8'
vim.opt.spell = true
vim.opt.spelllang = 'en,lt'

-- Search
vim.opt.ignorecase = true -- Ignore case when searching using lowercase
vim.opt.smartcase = true -- Ignore ignorecase if search contains upper case letters

vim.opt.grepprg = 'rg --vimgrep -M 160 -S'

vim.diagnostic.config({ virtual_text = true })
