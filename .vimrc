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
set shortmess+=c  " Don't pass messages to |ins-completion-menu|.
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
set bs=2        " same as ":set backspace=indent,eol,start"

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
nnoremap <silent> <home> g<home>
inoremap <silent> <home> <C-o>g<home>
nnoremap <silent> <end> g<end>
inoremap <silent> <end> <C-o>g<end>

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

augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END

function! NetrwMapping()
    nnoremap <buffer> gd :tabclose<CR>
    nnoremap <buffer> ga :tabnew<CR>
    nnoremap <buffer> gs :tab split<CR>
    nnoremap <buffer> go :tabonly<CR>
endfunction

" Faster navigation through code
:set grepprg=rg\ --vimgrep\ -M\ 160\ -S\ --

" Plugins

call plug#begin('~/.vim/plugged')

" Generic programming plugins
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v2.x' }

Plug 'github/copilot.vim'

Plug 'will133/vim-dirdiff'

Plug 'machakann/vim-sandwich'

Plug 'numToStr/Comment.nvim'

Plug 'vim-test/vim-test'
Plug 'rcarriga/vim-ultest', { 'do': ':UpdateRemotePlugins' }

Plug 'dense-analysis/ale'
" Plug '~/projects/ale'

Plug 'folke/trouble.nvim'

Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-omni'
Plug 'hrsh7th/cmp-emoji'
Plug 'hrsh7th/cmp-copilot'
Plug 'octaltree/cmp-look'
Plug 'hrsh7th/nvim-cmp'

Plug 'junegunn/vader.vim'
Plug 'jamessan/vim-gnupg'

Plug 'editorconfig/editorconfig-vim'

Plug 'sQVe/sort.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'windwp/nvim-ts-autotag'

" Git
Plug 'airblade/vim-gitgutter'
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

Plug 'sirtaj/vim-openscad'
call plug#end()

" Colors
colorscheme solarized

lua <<EOF
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

EOF

" Use TSHighlightCaptureUnderCursor to find good group
hi TSKeyword gui=italic cterm=italic
hi TSKeywordFunction gui=italic cterm=italic
hi TSInclude gui=italic cterm=italic
hi TSRepeat gui=italic cterm=italic
hi TSConditional gui=italic cterm=italic
hi TSType gui=italic cterm=italic
hi TSConstMacro gui=italic cterm=italic

" neo-tree
let g:neo_tree_remove_legacy_commands = 1
hi NeoTreeTitleBar guifg=#ffffff guibg=#586e75

lua <<EOF
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
EOF

" Ale

let js_fixers = ['prettier', 'eslint']

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': js_fixers,
\   'javascript.jsx': js_fixers,
\   'typescript': js_fixers,
\   'typescriptreact': js_fixers,
\   'css': ['prettier'],
\   'json': ['prettier'],
\}

let g:ale_fix_on_save = 1
let g:ale_send_to_neovim_diagnostics = 1
let g:ale_sign_column_always = 1
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
let g:ale_lsp_suggestions = 1
let g:ale_floating_preview = 1
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']

let g:ale_sign_error = "E"
let g:ale_sign_warning = "W"
let g:ale_sign_info = "I"

augroup ale-colors
  highlight ALEErrorSign ctermfg=9 ctermbg=15 guifg=#C30500
  highlight ALEWarningSign ctermfg=11 ctermbg=15 guifg=#ED6237
augroup END


command! ALEToggleFixer execute "let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1"

set completeopt=menu,menuone,noselect " nvim-cmp suggestion

lua require('Comment').setup()

" nvim-cmp
lua <<EOF
  local cmp = require'cmp'

  cmp.setup({
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
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end
    }),
    sources = cmp.config.sources({
      {
        name = 'buffer',
      },
      { name = 'omni' },
      { name = 'copilot' },
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
EOF

" sort.nvim

lua << EOF
  require("sort").setup({})
EOF

" lualine
lua <<EOF
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
        sources = {'ale'},
        sections = {'error', 'warn', 'info', 'hint'},
        symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'}
      }
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}

EOF

" Telescope
lua <<EOF
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

EOF

lua require'colorizer'.setup()

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

" gitgutter
let g:gitgutter_map_keys = 0

function! OpenURLUnderCursor()
  let s:uri = expand('<cWORD>')
  let s:uri = matchstr(s:uri, '[a-z]*:\/\/[^ >,;()]*')
  let s:uri = substitute(s:uri, '?', '\\?', '')
  let s:uri = shellescape(s:uri, 1)
  if s:uri != ''
    if has('macunix')
      silent exec "!open '".s:uri."'"
    else
      silent exec "!xdg-open '".s:uri."'"
    endif
    :redraw!
  endif
endfunction
nnoremap gx :call OpenURLUnderCursor()<CR>

" vim-ultest

let g:ultest_use_pty = 1

augroup UltestRunner
    au!
    au BufWritePost * UltestNearest
augroup END

hi UltestPass ctermfg=Green guifg=#40AA40
hi UltestFail ctermfg=Red guifg=#CC6060
hi UltestRunning ctermfg=Yellow guifg=#FFEC63
hi UltestBorder ctermfg=Red guifg=#CC6060
hi UltestSummaryInfo ctermfg=cyan guifg=#4040AA gui=bold cterm=bold

let g:ultest_running_sign="●"
let g:ultest_output_on_line=0

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

nnoremap <leader>d :ALEGoToDefinition<CR>
nnoremap <leader>k :ALEHover<CR>

nnoremap <leader>aj :ALENext -error<cr>
nnoremap <leader>ak :ALEPrevious -error<cr>
nnoremap <leader>ac :ALECodeAction<CR>
vnoremap <leader>ac :ALECodeAction<CR>
nnoremap <leader>ar :ALERename<CR>
nnoremap <leader>at :ALEGoToTypeDefinition<CR>
nnoremap <leader>af :ALEFindReferences -quickfix<CR>

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

nnoremap <leader>uf <Plug>(ultest-run-file)
nnoremap <leader>un <Plug>(ultest-run-nearest)
nnoremap <leader>us <Plug>(ultest-summary-toggle)
nnoremap <leader>uj <Plug>(ultest-next-fail)
nnoremap <leader>uk <Plug>(ultest-prev-fail)
nnoremap <leader>uo <Plug>(ultest-output-show)

" date
iabbrev <expr> ,d strftime('%Y-%m-%d')

command! -bang -nargs=1 Rg execute "Telescope live_grep theme=ivy default_text=" . fnameescape("<args>")

:cnoreabbrev <expr> rg (getcmdtype() == ':' && getcmdline() ==# 'rg') ? 'Rg' : 'rg'

" vimrc file
nnoremap <leader>v :e ~/.vimrc<cr>

" terminal
tnoremap <leader>e <C-\><C-n>

" Misc

function! RenameAll()
    let l:frompart = input("Rename from: ", expand("<cword>"))
    let l:topart = input("Rename to: " , l:frompart)
    execute ':gr ' . frompart
    execute ':cfdo %s/' . frompart . '/' . topart . '/g'
    execute ':wa'
endfunction

command RenameAll call RenameAll()
