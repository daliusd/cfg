let g:python3_host_prog = expand('~').'/projects/soft/py3nvim/bin/python'

" UI part

if has('nvim')
  set clipboard+=unnamedplus

  set autoread
  au FocusGained * :checktime
endif

set mouse=a     " Enable mouse for everything

syntax spell
syntax on
set termguicolors
set background=light
set hidden " Allow opening new buffer without saving or opening it in new tab
set noshowmode " This is shown by line plugin already so I don't need NORMAL/INSERT/... in command line

set wildmenu    " better command-line completion
set list listchars=trail:.,tab:▷▷⋮ " Show trailing dots and tabs

set scrolloff=3     " Keep 3 lines below and above the cursor
set number          " Show line numbering
set numberwidth=1   " Use 1 col + 1 space for numbers

" Vim stuff
set nofixeol    " Let's not fix end-of-line

set nobackup
set noswapfile
set nowritebackup
set directory=/tmp
set undofile
set undodir=/tmp

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
set completeopt=menu,menuone,noselect " nvim-cmp suggestion
set signcolumn=number " merge signcolumn and number column into one
set showtabline=2

set diffopt+=vertical " Vertical diff

" We want string-like-this to be treated as word. That however means that proper spacing must
" be used in arithmetic operations.
set iskeyword+=-

" Indentation and Tab
set autoindent
set expandtab
set smarttab
set sw=2        " Spaces per indent

set tabstop=8   " Number of spaces per tab. People usually use 4, but they shouldn't use tab in the first place.

set foldmethod=indent " syntax folding method makes prettier fixer slower

set foldlevelstart=99
filetype plugin indent on

" Encodings and spelling
set fileencodings=utf-8,ucs-bom,latin1
set encoding=utf-8
set spell
set spelllang=en,lt

" Search
set hlsearch    " Highlight search
set incsearch   " Show search as you type
set ignorecase  " Ignore case when searching using lowercase
set smartcase   " Ignore ignorecase if search contains upper case letters


" Better navigation for wrapped lines.
nnoremap j gj
nnoremap k gk
nnoremap <silent> <up> gk
inoremap <silent> <up> <C-o>gk
nnoremap <silent> <down> gj
inoremap <silent> <down> <C-o>gj

" Command mode up/down remap
cnoremap <c-k> <up>
cnoremap <c-j> <down>

" Next/Previous result
nnoremap <C-n> :cn<cr>
nnoremap <C-p> :cp<cr>

nnoremap ; :
vnoremap ; :

" Leader commands
let mapleader = " "

" The 66-character line (counting both letters and spaces) is widely regarded as ideal.
" http://webtypography.net/Rhythm_and_Proportion/Horizontal_Motion/2.1.2/
au BufRead,BufNewFile *.md     setlocal textwidth=66
au BufRead,BufNewFile *.rst     setlocal textwidth=66

" Tab navigation
nnoremap <c-j> :tabnext<CR>
nnoremap <c-k> :tabprev<CR>
inoremap <c-j> <c-o>:tabnext<CR>
inoremap <c-k> <c-o>:tabprev<CR>
nnoremap <c-l> :tabm +1<CR>
nnoremap <c-h> :tabm -1<CR>
nnoremap <c-down> :tabnext<CR>
nnoremap <c-up> :tabprev<CR>
nnoremap <c-right> :tabm +1<CR>
nnoremap <c-left> :tabm -1<CR>

nnoremap gd :tabclose<CR>
nnoremap ga :tabnew<CR>
nnoremap gs :tab split<CR>
nnoremap go :tabonly<CR>

nnoremap <silent> gh <Cmd>Sort<CR>
vnoremap <silent> gh <Esc><Cmd>Sort<CR>

" Faster navigation through code
:set grepprg=rg\ --vimgrep\ -M\ 160\ -S

" Plugins

call plug#begin('~/.vim/plugged')

" Generic programming plugins
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

Plug 'akinsho/toggleterm.nvim'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v2.x' }

Plug 'will133/vim-dirdiff'

Plug 'machakann/vim-sandwich'

Plug 'numToStr/Comment.nvim'

Plug 'vim-test/vim-test'
Plug 'antoinemadec/FixCursorHold.nvim' " Required by neotest
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-vim-test'

Plug 'neovim/nvim-lspconfig'
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'jose-elias-alvarez/typescript.nvim'

Plug 'folke/trouble.nvim'

Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-emoji'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'octaltree/cmp-look'
Plug 'hrsh7th/nvim-cmp'

Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'rafamadriz/friendly-snippets'

Plug 'junegunn/vader.vim'
Plug 'jamessan/vim-gnupg'

Plug 'editorconfig/editorconfig-vim'

Plug 'sQVe/sort.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'windwp/nvim-ts-autotag'

" Git
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

" Tree-sitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'lewis6991/spellsitter.nvim'

" Status line
Plug 'hoob3rt/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'sangdol/mintabline.vim'

" Other

Plug 'ishan9299/nvim-solarized-lua'
Plug 'norcalli/nvim-colorizer.lua'

call plug#end()

" Colors
colorscheme solarized

lua <<EOF

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

require('spellsitter').setup()

-- neotree

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

require("neo-tree").setup({
        window = {
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["i"] = { "toggle_node" },
          }
        },
      })

-- nvim-lspconfig

vim.lsp.handlers['textDocument/references'] = vim.lsp.with(
    vim.lsp.handlers['textDocument/references'], {
        no_qf_window = true,
    }
)

vim.lsp.handlers['textDocument/declaration'] = vim.lsp.with(
    vim.lsp.handlers['textDocument/declaration'], {
        no_qf_window = true,
    }
)

vim.lsp.handlers['textDocument/definition'] = vim.lsp.with(
    vim.lsp.handlers['textDocument/definition'], {
        no_qf_window = true,
    }
)

vim.lsp.handlers['textDocument/typeDefinition'] = vim.lsp.with(
    vim.lsp.handlers['textDocument/typeDefinition'], {
        no_qf_window = true,
    }
)

vim.lsp.handlers['textDocument/implementation'] = vim.lsp.with(
    vim.lsp.handlers['textDocument/implementation'], {
        no_qf_window = true,
    }
)

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>ak', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<leader>aj', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>aq', vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<leader>ad', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, bufopts)

  vim.keymap.set('n', '<leader>ai', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<leader>ah', vim.lsp.buf.signature_help, bufopts)

  vim.keymap.set('n', '<leader>at', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>ar', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ac', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('v', '<leader>ac', vim.lsp.buf.range_code_action, bufopts)
  vim.keymap.set('n', '<leader>af', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>ap', vim.lsp.buf.formatting, bufopts)

  if client.name ~= 'null-ls' then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

require('lspconfig')['tsserver'].setup({})

require("typescript").setup({
  server = {
    on_attach = on_attach,
    capabilities = capabilities
  }

})

local null_ls = require("null-ls")
local command_resolver = require("null-ls.helpers.command_resolver")

local dynamic_command = function(params)
  return command_resolver.from_node_modules(params)
    or vim.fn.executable(params.command) == 1 and params.command
end

null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.trail_space,
        null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.formatting.trim_whitespace,
        null_ls.builtins.diagnostics.tsc.with({
          dynamic_command = dynamic_command,
        }),
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.formatting.prettier.with({
          dynamic_command = dynamic_command,
        }),
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.diagnostics.write_good,
        null_ls.builtins.code_actions.gitsigns,
    },
    on_attach = on_attach
    -- debug = true,
})

require('Comment').setup()

-- nvim-cmp

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

-- toggleterm

require("toggleterm").setup{
  open_mapping = [[<c-\>]],
  shade_terminals = false,
}

function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- sort.nvim
require("sort").setup({})

-- gitsigns
require('gitsigns').setup()

-- lualine

require('lualine').setup{
  options = {
    theme = 'solarized_light'
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
}

-- Telescope
local actions = require("telescope.actions")

require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<c-c>"] = false,
                ["<c-j>"] = actions.move_selection_next,
                ["<c-k>"] = actions.move_selection_previous,
            },
        },
    },
})

require('telescope').load_extension('fzf')

require'colorizer'.setup()

-- neotest
require("neotest").setup({
  adapters = {
    require("neotest-vim-test")({
      ignore_file_types = { "vim", "lua" },
    }),
  },
  diagnostic = {
    enabled = true
  },
  highlights = {
    test = "NeotestTest"
  },
  icons = {
    running = "●",
  },
})

-- Use TSHighlightCaptureUnderCursor to find good group
vim.cmd('hi TSKeyword gui=italic cterm=italic')
vim.cmd('hi TSKeywordFunction gui=italic cterm=italic')
vim.cmd('hi TSInclude gui=italic cterm=italic')
vim.cmd('hi TSRepeat gui=italic cterm=italic')
vim.cmd('hi TSConditional gui=italic cterm=italic')
vim.cmd('hi TSType gui=italic cterm=italic')
vim.cmd('hi TSConstMacro gui=italic cterm=italic')

vim.cmd('hi NeoTreeTitleBar guifg=#ffffff guibg=#586e75')

vim.cmd('hi NeotestPassed ctermfg=Green guifg=#40AA40')
vim.cmd('hi NeotestFailed ctermfg=Red guifg=#CC6060')
vim.cmd('hi NeotestRunning ctermfg=Yellow guifg=#FFEC63')
vim.cmd('hi NeotestBorder ctermfg=Red guifg=#CC6060')

EOF

" My todo files
au BufRead,BufNewFile *.todo        setlocal filetype=todo
au BufRead,BufNewFile *.todo        setlocal foldmethod=indent

" editorconfig-vim
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

function! GetLastMessage()
  execute ":redir @+"
  execute ":1messages"
  execute ":redir END"
endfunction

" Fugitive
:cnoreabbrev <expr> gps (getcmdtype() == ':' && getcmdline() ==# 'gps') ? 'Git push' : 'gps'
:cnoreabbrev <expr> gpl (getcmdtype() == ':' && getcmdline() ==# 'gpl') ? 'Git pull' : 'gpl'
:cnoreabbrev <expr> gs (getcmdtype() == ':' && getcmdline() ==# 'gs') ? 'Git' : 'gs'
:cnoreabbrev <expr> gd (getcmdtype() == ':' && getcmdline() ==# 'gd') ? 'Gdiffsplit' : 'gd'
:cnoreabbrev <expr> gb (getcmdtype() == ':' && getcmdline() ==# 'gb') ? 'Git blame' : 'gb'


let g:test#runner_commands = ['VSpec', 'Jest', 'Playwright']

" Leader config

nnoremap <silent> <leader>n :silent noh<CR>
nnoremap <leader>q :qa<CR>

nnoremap <leader>i :let @+ = expand('%:t')<cr>
nnoremap <leader>o :let @+ = expand('%')<cr>
nnoremap <leader>p :let @+ = expand('%:p')<cr>

nnoremap <leader>h :Telescope oldfiles theme=ivy<cr>
nnoremap <leader>f :Telescope find_files theme=ivy<cr>
nnoremap <leader>r :Telescope grep_string theme=ivy<cr>
nnoremap <leader>g :silent gr <cword><cr>
nnoremap <leader>t :Telescope live_grep theme=ivy<cr>
nnoremap <leader>c :Telescope commands theme=ivy<cr>

nnoremap <leader>l :call GetLastMessage()<cr>

nnoremap <leader>s :update<cr>
nnoremap <leader>x :TroubleToggle<cr>
nnoremap <leader>b :Neotree left filesystem reveal toggle<cr>
nnoremap - :Neotree float filesystem reveal reveal_force_cwd<cr>

" window commands
nnoremap <leader>ww <c-w>w
nnoremap <leader>wc <c-w>c
nnoremap <leader>wo <c-w>o
nnoremap <leader>wh <c-w>h
nnoremap <leader>wj <c-w>j
nnoremap <leader>wk <c-w>k
nnoremap <leader>wl <c-w>l

nnoremap <leader>uf :lua require("neotest").run.run(vim.fn.expand("%"))<cr>
nnoremap <leader>un :lua require("neotest").run.run()<cr>
nnoremap <leader>us :lua require("neotest").summary.toggle()<cr>
nnoremap <leader>uj :lua require("neotest").jump.next({ status = "failed" })<cr>
nnoremap <leader>uk :lua require("neotest").jump.prev({ status = "failed" })<cr>
nnoremap <leader>uo :lua require("neotest").output.open({ enter = true })<cr>

" date
iabbrev <expr> ,d strftime('%Y-%m-%d')

command! -bang -nargs=1 Rg execute "Telescope live_grep theme=ivy default_text=" . fnameescape("<args>")

:cnoreabbrev <expr> rg (getcmdtype() == ':' && getcmdline() ==# 'rg') ? 'Rg' : 'rg'

function! YoshiTest()
  let g:test#javascript#runner = 'jest'
  let g:test#javascript#jest#executable='yarn yoshi test'
endfunction

command YoshiTest call YoshiTest()

" vimrc file
nnoremap <leader>v :e ~/.vimrc<cr>

" Misc

function! RenameAll()
    let l:frompart = input("Rename from: ", expand("<cword>"))
    let l:topart = input("Rename to: " , l:frompart)
    execute ':gr ' . frompart
    execute ':cfdo %s/' . frompart . '/' . topart . '/g'
    execute ':wa'
endfunction

command RenameAll call RenameAll()

function! FormatJSON()
  exe '%!python3 -m json.tool'
  set filetype=json
endfunction

command FormatJSON call FormatJSON()

function! FormatSHTOUT()
  exe ':%!node ~/bin/sht.js'
  set filetype=json
endfunction

command FormatSHTOUT call FormatSHTOUT()

function! UnformatSHTOUT()
  exe ':%!node ~/bin/usht.js'
  set filetype=json
endfunction

command UnformatSHTOUT call UnformatSHTOUT()

function! UnformatJSON()
  exe ':%!node ~/bin/unjson.js'
  set filetype=
endfunction

command UnformatJSON call UnformatJSON()

command FormatHtml execute "%!tidy -q -i --show-errors 0"
command FormatXml execute "%!tidy -q -i --show-errors 0 -xml"
