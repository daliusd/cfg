local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

vim.g.mapleader = ' ' -- we need to setup this before plugins

function vim.getVisualSelection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end

local keymap = vim.keymap.set
local opts = { noremap=true, silent=true }


require("lazy").setup({
  {
    "mcchrish/zenbones.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g['zenbones_compat'] = 1
      vim.cmd([[colorscheme zenbones]])
    end,
  },
  {
    "dstein64/vim-startuptime",
    -- lazy-load on a command
    cmd = "StartupTime",
  },

  -- Generic plugins

  'kyazdani42/nvim-web-devicons',
  "hoob3rt/lualine.nvim",
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
  },
  'nvim-lua/plenary.nvim',
  {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim',
    'marcuscaisey/olddirs.nvim',
  },

  config = function()
    local actions = require("telescope.actions")
    local lga_actions = require("telescope-live-grep-args.actions")

    require("telescope").setup({
        defaults = {
            mappings = {
                i = {
                    ["<esc>"] = actions.close,
                    ["<c-c>"] = false,
                    ["<c-j>"] = actions.move_selection_next,
                    ["<c-k>"] = actions.move_selection_previous,
                    ["<C-u>"] = actions.results_scrolling_up,
                    ["<C-d>"] = actions.results_scrolling_down,
                },
            },
        },
        extensions = {
          live_grep_args = {
              mappings = {
                  i = {
                    ["<C-f>"] = lga_actions.quote_prompt({ postfix = " -g *" }),
                    ["<C-l>"] = lga_actions.quote_prompt({ postfix = " -g *en*" }),
                  },
              },
          },
        },
    })

    local telescope = require('telescope')
    telescope.load_extension('fzf')
    telescope.load_extension('live_grep_args')
    telescope.load_extension('olddirs')
  end,
  cmd = { 'Telescope' },
  keys = {
    {'<leader>h', ':Telescope oldfiles theme=ivy<cr>'},
    {'<leader>f', ':Telescope find_files theme=ivy<cr>'},
    {'<leader>y', function() require('telescope').extensions.olddirs.picker() end},
    {'<leader>r', function()
      local text = vim.fn.expand("<cword>")
      vim.fn.histadd(':', 'Rg ' .. text)
      require('telescope').extensions.live_grep_args.live_grep_args({ default_text = text, theme = 'ivy' })
    end
    },
    {'<leader>r', function()
      local text = vim.getVisualSelection()
      vim.fn.histadd(':', 'Rg ' .. text)
      require('telescope').extensions.live_grep_args.live_grep_args({ default_text = text, theme = 'ivy' })
    end,
    mode = 'v'
    },
    {'<leader>t', ':Telescope live_grep_args theme=ivy<cr>'},
    {'<leader>c', ':Telescope commands theme=ivy<cr>'},
    }
  },
  "MunifTanjim/nui.nvim",
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    keys = {
      { "<leader>b", ":Neotree left filesystem reveal toggle<cr>", desc = "NeoTree" },
      { "-", ":Neotree float filesystem reveal reveal_force_cwd<cr>", desc = "NeoTree CWD" },
    },
    config = function()
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

      require("neo-tree").setup({
        window = {
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["i"] = { "toggle_node" },
            ["<esc>"] = "close_window",
          }
        },
      })
    end,
  },
  'rcarriga/nvim-notify',
  'folke/noice.nvim',
  {
    'sindrets/diffview.nvim',
    cmd = {'DiffviewOpen', 'DiffviewFileHistory'},
  },
  'tpope/vim-surround',
  'tpope/vim-abolish',

  'justinmk/vim-sneak',
  {
    'numToStr/Comment.nvim',
    config = true,
  },
  'vim-test/vim-test',
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/neotest-vim-test',
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-vim-test")({
            ignore_file_types = { "vim", "lua" },
          }),
        },
        diagnostic = {
          enabled = true
        },
        floating = {
          max_height = 0.9,
          max_width = 0.9
        },
        highlights = {
          test = "NeotestTest"
        },
        icons = {
          passed = "✔",
          running = "🏃",
          failed = "✖",
          skipped = "ﰸ",
          unknown = "?",
        },
      })
    end,
    keys = {
      {'<leader>uf', function() require("neotest").run.run(vim.fn.expand("%")) end},
      {'<leader>un', function() require("neotest").run.run() end},
      {'<leader>us', function() require("neotest").summary.toggle() end},
      {'<leader>uj', function() require("neotest").jump.next({ status = "failed" }) end},
      {'<leader>uk', function() require("neotest").jump.prev({ status = "failed" }) end},
      {'<leader>uo', function() require("neotest").output.open({ enter = true }) end},
    },
  },
  'neovim/nvim-lspconfig',
  'jose-elias-alvarez/null-ls.nvim',
  'jose-elias-alvarez/typescript.nvim',
  {
  'hrsh7th/nvim-cmp',
  event = "InsertEnter",
  dependencies = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-emoji',
    'hrsh7th/cmp-nvim-lsp',
    'octaltree/cmp-look',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',
    'rafamadriz/friendly-snippets',
    },
  config = function()
    local cmp = require'cmp'

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
      },
      window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<Tab>'] = function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        {
          name = 'buffer',
          option = {
            keyword_pattern = [[\k\+]],
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end
          }
        },
        { name = 'emoji' },
        { name = 'path' },
      }, {
        {
          name = 'look',
          keyword_length = 2,
          option = {
            convert_case = true,
            loud = true
          }
        }
      })
    })

    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    })

    require('nvim-autopairs').setup{}
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))
  end,
  },
  'jamessan/vim-gnupg',

  'editorconfig/editorconfig-vim',

  {
    'sQVe/sort.nvim',
    config = true,
  },
  'windwp/nvim-autopairs',
  'windwp/nvim-ts-autotag',

  -- Git
  {
    'lewis6991/gitsigns.nvim',
    config = true,
  },
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Tree-sitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },
  'nvim-treesitter/playground',
  {
    'lewis6991/spellsitter.nvim',
    config = true,
  },
  {
    'anuvyklack/pretty-fold.nvim',
    config = true,
  },
  -- Other
  {
    'norcalli/nvim-colorizer.lua',
  },
  {
    'uga-rosa/translate.nvim',
    cmd = 'Translate',
    config = function()
      require("translate").setup({
        default = {
          output = "replace",
        },
      })
    end
  },
}, {
  checker = {
    -- automatically check for plugin updates
    enabled = true,
    notify = true,
    frequency = 7200,
  },
})

--

vim.g.python3_host_prog = vim.fn.expand('~') .. '/projects/soft/py3nvim/bin/python'

-- UI part

vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true

vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })

vim.opt.background = 'light'
vim.opt.hidden = true -- Allow opening new buffer without saving or opening it in new tab
vim.opt.showmode = false -- This is shown by line plugin already so I don't need NORMAL/INSERT/... in command line

vim.opt.list = true
vim.opt.listchars = ({ trail = '.', tab = ':▷⋮' }) -- Show trailing dots and tabs

vim.opt.scrolloff = 3   -- Keep 3 lines below and above the cursor
vim.opt.number = true   -- Show line numbering
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
vim.opt.signcolumn = 'number' -- merge signcolumn and number column into one
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

-- fold fix https://github.com/nvim-telescope/telescope.nvim/issues/559
-- autocmd BufRead * autocmd BufWinEnter * ++once normal! zx

vim.opt.foldlevelstart = 99

-- Encodings and spelling
vim.opt.fileencodings = 'utf-8,ucs-bom,latin1'
vim.opt.encoding = 'utf-8'
vim.opt.spell = true
vim.opt.spelllang = 'en,lt'

-- Search
vim.opt.ignorecase = true  -- Ignore case when searching using lowercase
vim.opt.smartcase = true   -- Ignore ignorecase if search contains upper case letters

vim.opt.grepprg = 'rg --vimgrep -M 160 -S'

-- Keymaps

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

-- The 66-character line (counting both letters and spaces) is widely regarded as ideal.
-- http://webtypography.net/Rhythm_and_Proportion/Horizontal_Motion/2.1.2/
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { pattern = '*.md', command = "setlocal textwidth=66" })

local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

--- Highlight yanked text

au('TextYankPost', {
  group = ag('yank_highlight', {}),
  pattern = '*',
  callback = function()
    vim.highlight.on_yank { higroup='IncSearch', timeout=300 }
  end,
})

require'colorizer'.setup()

-- noice

require("noice").setup({
  messages = {
    view_search = "mini",
  }
})

-- nvim-treesitter

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = false,
    disable = {},
  },
  autotag = {
    enable = true,
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}

-- nvim-lspconfig

local function filter(arr, fn)
  if type(arr) ~= "table" then
    return arr
  end

  local filtered = {}
  for k, v in pairs(arr) do
    if fn(v, k, arr) then
      table.insert(filtered, v)
    end
  end

  return filtered
end

local function filterReactDTS(value)
  return string.match(value.filename, 'react/index.d.ts') == nil
end

local function on_list(options)
  -- https://github.com/typescript-language-server/typescript-language-server/issues/216
  local items = options.items
  if #items > 1 then
    items = filter(items, filterReactDTS)
  end

  vim.fn.setqflist({}, ' ', { title = options.title, items = items, context = options.context })
  vim.api.nvim_command('cfirst')
end

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>ak', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<leader>aj', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>aq', vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<leader>ad', function() vim.lsp.buf.declaration{on_list=on_list} end, bufopts)
  -- vim.keymap.set('n', '<leader>d', function() vim.lsp.buf.definition{on_list=on_list} end, bufopts)
  vim.keymap.set('n', '<leader>d', '<c-]>', bufopts)
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, bufopts)

  vim.keymap.set('n', '<leader>ai', function() vim.lsp.buf.implementation{on_list=on_list} end, bufopts)
  vim.keymap.set('n', '<leader>ah', vim.lsp.buf.signature_help, bufopts)

  vim.keymap.set('n', '<leader>at', function() vim.lsp.buf.type_definition{on_list=on_list} end, bufopts)
  vim.keymap.set('n', '<leader>ar', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ac', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('v', '<leader>ac', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>af', function() vim.lsp.buf.references(nil, {on_list=on_list}) end, bufopts)

  if client.name ~= 'null-ls' then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

require('lspconfig')['tsserver'].setup({})

require("typescript").setup({
  server = {
    on_attach = on_attach,
    capabilities = capabilities
  }

})

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.trail_space,
        null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.formatting.trim_whitespace,
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.diagnostics.write_good,
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.hover.dictionary,
    },
    on_attach = on_attach
    -- debug = true,
})

-- Use internal formatting for bindings like gq.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.bo[args.buf].formatexpr = nil
  end,
})

-- lualine

require('lualine').setup{
  options = {
    theme = 'zenbones'
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {
      {
        'filename',
        path = 1
      }
    },
    lualine_x = {'encoding', 'fileformat', 'filetype',
      {
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        sections = {'error', 'warn', 'info', 'hint'},
        symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'}
      }
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  tabline = {
    lualine_a = {
      {
          'tabs',
          max_length = vim.o.columns,
          mode = 2,
          tabs_color = { active = 'lualine_a_normal', inactive = 'lualine_c_normal' },
          fmt = function(name, context)
            local buflist = vim.fn.tabpagebuflist(context.tabnr)
            local winnr = vim.fn.tabpagewinnr(context.tabnr)
            local bufnr = buflist[winnr]
            local mod = vim.fn.getbufvar(bufnr, '&mod')

            return name .. (mod == 1 and ' +' or '')
          end

      },
    },
    lualine_z = {'filesize'}
  },
}

-- Telescope

local opts = { noremap = true, silent = true }

keymap('n', '<leader>g', function()
  local text = vim.fn.expand("<cword>")
  vim.fn.histadd(':', 'gr ' .. text)
  vim.cmd('silent gr ' .. text)
end, opts)

keymap('v', '<leader>g', function()
  local text = vim.getVisualSelection()
  vim.fn.histadd(':', 'gr ' .. text)
  vim.cmd('silent gr ' .. text)
end, opts)

-- Use TSHighlightCaptureUnderCursor to find good group

vim.cmd('hi NeoTreeTitleBar guifg=#ffffff guibg=#586e75')

vim.cmd('hi NeotestPassed ctermfg=Green guifg=#40AA40')
vim.cmd('hi NeotestFailed ctermfg=Red guifg=#CC6060')
vim.cmd('hi NeotestRunning ctermfg=Yellow guifg=#FFEC63')
vim.cmd('hi NeotestBorder ctermfg=Red guifg=#CC6060')

vim.cmd('hi NotifyERRORTitle guifg=#8a1f1f')
vim.cmd('hi NotifyINFOIcon guifg=#4f6752')
vim.cmd('hi NotifyINFOTitle guifg=#4f6752')

-- My todo files
vim.api.nvim_create_autocmd(
  { 'BufRead', 'BufNewFile' },
  { pattern = '*.todo', command = 'setlocal filetype=todo' }
)

vim.api.nvim_create_autocmd(
  { 'BufRead', 'BufNewFile' },
  { pattern = '*.todo', command = 'setlocal foldmethod=indent' }
)

-- editorconfig-vim
vim.g['EditorConfig_exclude_patterns'] = {'fugitive://.*'}

-- Fugitive
vim.cmd(":cnoreabbrev <expr> gps (getcmdtype() == ':' && getcmdline() ==# 'gps') ? 'Git push' : 'gps'")
vim.cmd(":cnoreabbrev <expr> gpl (getcmdtype() == ':' && getcmdline() ==# 'gpl') ? 'Git pull' : 'gpl'")
vim.cmd(":cnoreabbrev <expr> gs (getcmdtype() == ':' && getcmdline() ==# 'gs') ? 'Git' : 'gs'")
vim.cmd(":cnoreabbrev <expr> gd (getcmdtype() == ':' && getcmdline() ==# 'gd') ? 'Gdiffsplit' : 'gd'")
vim.cmd(":cnoreabbrev <expr> gb (getcmdtype() == ':' && getcmdline() ==# 'gb') ? 'Git blame' : 'gb'")
vim.cmd(":cnoreabbrev <expr> gbr (getcmdtype() == ':' && getcmdline() ==# 'gbr') ? 'GBrowse' : 'gbr'")


vim.g.fugitive_legacy_commands = 1

-- Test runner
vim.g['test#runner_commands'] = {'VSpec', 'Jest', 'Playwright'}

-- Leader config

keymap('n', '<leader>l', ':Lazy<cr>', ops)

keymap('n', '<leader>n', ':silent noh<cr>', ops)
keymap('n', '<leader>q', ':qa<cr>', ops)

keymap('n', '<leader>i', ":let @+ = expand('%:t')<cr>", ops)
keymap('n', '<leader>o', ":let @+ = expand('%')<cr>", ops)
keymap('n', '<leader>p', ":let @+ = expand('%:p')<cr>", ops)

keymap('n', '<leader>s', ':w<cr>', ops)

-- window commands

keymap('n', '<leader>ww', '<c-w>w', ops)
keymap('n', '<leader>wc', '<c-w>c', ops)
keymap('n', '<leader>wo', '<c-w>o', ops)
keymap('n', '<leader>wh', '<c-w>h', ops)
keymap('n', '<leader>wj', '<c-w>j', ops)
keymap('n', '<leader>wk', '<c-w>k', ops)
keymap('n', '<leader>wl', '<c-w>l', ops)


-- vimrc file
keymap('n', '<leader>v', ':e ~/.config/nvim/lua/init.lua<cr>', ops)

-- date
vim.cmd("iabbrev <expr> ,d strftime('%Y-%m-%d')")
vim.cmd("iabbrev <expr> ,t strftime('%Y-%m-%d %T')")

vim.cmd('command! -bang -nargs=1 Rg execute ":Telescope live_grep_args theme=ivy default_text=" . escape(<q-args>, \' \\\')')

vim.cmd(":cnoreabbrev <expr> rg (getcmdtype() == ':' && getcmdline() ==# 'rg') ? 'Rg' : 'rg'")

-- Commands

vim.api.nvim_create_user_command(
  'YoshiTest',
  function()
    vim.g['test#javascript#runner'] = 'jest'
    vim.g['test#javascript#jest#executable'] = 'yarn yoshi test'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'YoshiLibraryTest',
  function()
    vim.g['test#javascript#runner'] = 'jest'
    vim.g['test#javascript#jest#executable'] = 'yarn yoshi-library test'
  end,
  {}
)

-- format/unformat

vim.api.nvim_create_user_command(
  'FormatJSON',
  function()
    vim.cmd('%!python3 -m json.tool')
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'UnformatJSON',
  function()
    vim.cmd(':%!node ~/bin/unjson.js')
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatSHTOUT',
  function()
    vim.cmd(":%!node ~/bin/sht.js")
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'UnformatSHTOUT',
  function()
    vim.cmd(":%!node ~/bin/usht.js")
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatHtml',
  function()
    vim.cmd("%!tidy -q -i --show-errors 0")
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatXml',
  function()
    vim.cmd("%!tidy -q -i --show-errors 0 -xml")
  end,
  {}
)
