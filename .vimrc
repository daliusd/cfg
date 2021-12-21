let g:python3_host_prog = expand('~').'/projects/soft/py3nvim/bin/python'

" UI part

if has('nvim')
  set clipboard+=unnamedplus

  set autoread
  au FocusGained * :checktime
endif

set mouse=a     " Enable mouse for everything

syntax spell toplevel
syntax enable
set termguicolors
set background=light
set hidden " Allow opening new buffer without saving or opening it in new tab
set noshowmode " This is shown by line plugin already so I don't need NORMAL/INSERT/... in command line

set wildmenu    " better command-line completion
set list listchars=trail:.,tab:>- " Show trailing dots and tabs

set scrolloff=3     " Keep 3 lines below and above the cursor
set number          " Show line numbering
set numberwidth=1   " Use 1 col + 1 space for numbers

set synmaxcol=500   " should make slightly faster than 3000

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
:set iskeyword+=-

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
let mapleader = ","

function! FormatJSON()
  exe '%!python -m json.tool'
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

command FormatHtml execute "%!tidy -q -i --show-errors 0"
command FormatXml execute "%!tidy -q -i --show-errors 0 -xml"

" The 66-character line (counting both letters and spaces) is widely regarded as ideal.
" http://webtypography.net/Rhythm_and_Proportion/Horizontal_Motion/2.1.2/
au BufRead,BufNewFile *.md     setlocal textwidth=66
au BufRead,BufNewFile *.rst     setlocal textwidth=66

" Tab navigation
nnoremap <c-j> :tabnext<CR>
nnoremap <c-k> :tabprev<CR>
nnoremap <c-l> :tabm +1<CR>
nnoremap <c-h> :tabm -1<CR>

nnoremap td :tabclose<CR>
nnoremap ta :tabnew<CR>
nnoremap tn :tabnew<CR>
nnoremap ts :tab split<CR>
nnoremap to :tabonly<CR>

augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END

function! NetrwMapping()
    nnoremap <buffer> tt :tabnew<CR>
    nnoremap <buffer> td :tabclose<CR>
    nnoremap <buffer> ta :tabnew<CR>
    nnoremap <buffer> ts :tab split<CR>
    nnoremap <buffer> to :tabonly<CR>
endfunction

" Faster navigation through code
:set grepprg=rg\ --vimgrep\ -M\ 160\ -S

" Plugins

call plug#begin('~/.vim/plugged')

" Generic programming plugins
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'github/copilot.vim'

Plug 'will133/vim-dirdiff'

Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

Plug 'dense-analysis/ale'
" Plug '~/projects/ale'

Plug 'Shougo/deoplete.nvim'
Plug 'ujihisa/neco-look'
Plug 'ncm2/float-preview.nvim'

Plug 'junegunn/vader.vim'
Plug 'jamessan/vim-gnupg'

Plug 'editorconfig/editorconfig-vim'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

Plug 'ruanyl/coverage.vim'

" Status line
Plug 'hoob3rt/lualine.nvim'

Plug 'kyazdani42/nvim-web-devicons'

Plug 'tamago324/lir.nvim'
Plug 'nvim-lua/plenary.nvim'

" Other
Plug 'ishan9299/nvim-solarized-lua'

Plug 'norcalli/nvim-colorizer.lua'
call plug#end()

" Colors
colorscheme solarized

:hi Statement gui=italic cterm=italic
:hi Conditional gui=italic cterm=italic
:hi Repeat gui=italic cterm=italic
:hi Operator gui=italic cterm=italic
":hi Keyword gui=italic cterm=italic
:hi Exception gui=italic cterm=italic

:hi Special gui=italic cterm=italic
:hi typescriptVariable gui=italic guifg=#268bd2 cterm=italic ctermfg=56
:hi typescriptFuncKeyword gui=italic guifg=#859900 cterm=italic ctermfg=56
:hi typescriptClassKeyword gui=italic guifg=#859900 cterm=italic ctermfg=56
:hi typescriptClassExtends gui=italic guifg=#859900 cterm=italic ctermfg=56
:hi typescriptInterfaceKeyword gui=italic guifg=#859900 cterm=italic ctermfg=56
:hi typescriptAliasKeyword gui=italic guifg=#859900 cterm=italic ctermfg=56
:hi javaScriptFunction gui=italic guifg=#859900 cterm=italic ctermfg=56
:hi javaScriptReserved gui=italic guifg=#859900 cterm=italic ctermfg=56

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
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = "🔥 "
let g:ale_sign_column_always = 1
let g:ale_completion_autoimport = 1
let g:ale_lsp_suggestions = 1
let g:ale_floating_preview = 1

let g:ale_sign_error = "E"
let g:ale_sign_warning = "W"
let g:ale_sign_info = "I"

augroup ale-colors
  highlight ALEErrorSign ctermfg=9 ctermbg=15 guifg=#C30500
  highlight ALEWarningSign ctermfg=11 ctermbg=15 guifg=#ED6237
augroup END


command! ALEToggleFixer execute "let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1"

" Deoplete

let g:deoplete#enable_at_startup = 1

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <C-j>   pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <C-k>   pumvisible() ? "\<C-p>" : "\<C-k>"

call deoplete#custom#var('buffer', 'require_same_filetype', v:false)

set completeopt-=preview
let g:float_preview#docked = 0

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

local actions = require'lir.actions'
local clipboard_actions = require'lir.clipboard.actions'

require'lir'.setup {
  show_hidden_files = true,
  devicons_enable = true,
  mappings = {
    ['<cr>']     = actions.edit,
    ['<C-s>'] = actions.split,
    ['<C-v>'] = actions.vsplit,
    ['<C-t>'] = actions.tabedit,

    ['-']     = actions.up,
    ['q']     = actions.quit,

    ['%']     = actions.mkdir,
    ['i']     = actions.newfile,
    ['r']     = actions.rename,
    ['@']     = actions.cd,
    ['y']     = actions.yank_path,
    ['.']     = actions.toggle_show_hidden,
    ['d']     = actions.delete,

    ['c'] = clipboard_actions.copy,
    ['x'] = clipboard_actions.cut,
    ['p'] = clipboard_actions.paste,
  },
  float = {
    winblend = 0,
  },
  hide_cursor = true,
}

vim.cmd [[augroup lir-settings]]
vim.cmd [[  autocmd!]]
vim.cmd [[  autocmd Filetype lir setlocal nospell]]
vim.cmd [[augroup END]]
EOF

lua require'colorizer'.setup()

" My todo files
au BufRead,BufNewFile *.todo        setlocal filetype=todo
au BufRead,BufNewFile *.todo        setlocal foldmethod=indent

" fzf
set rtp+=~/.fzf
let g:fzf_buffers_jump = 1
let g:fzf_layout = { 'up' : '100%' }
let g:fzf_preview_window = ['up:50%', 'ctrl-s']

command! -bang -nargs=* Rgw
    \ call fzf#vim#grep("rg --vimgrep --smart-case -w ".shellescape(expand('<cword>')), 1,
    \                   fzf#vim#with_preview(),
    \                   <bang>0)

:cnoreabbrev rg Rg

" editorconfig-vim
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" coverage.vim
let g:coverage_json_report_path = 'coverage/coverage-final.json'

function! GetLastMessage()
  execute ":redir @+"
  execute ":1messages"
  execute ":redir END"
endfunction

" Fugitive
:cnoreabbrev gps Git push
:cnoreabbrev gpl Git pull
:cnoreabbrev gs Git
:cnoreabbrev gd Gdiffsplit
:cnoreabbrev gb Git blame

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

" Leader config

nnoremap <leader>o <c-o>
nnoremap <leader>t <c-t>
nnoremap <silent> <leader>n :silent noh<CR>
nnoremap <leader>q :qa<CR>

nnoremap <leader>pf :let @+ = expand('%:p')<cr>
nnoremap <leader>pp :let @+ = expand('%')<cr>
nnoremap <leader>pn :let @+ = expand('%:t')<cr>

nnoremap <leader>c :Commands<cr>

nnoremap <leader>id "=strftime("%Y-%m-%d ")<CR>P

nnoremap <leader>h :History<cr>
nnoremap <leader>f :Files<cr>
nnoremap <leader>s :Rgw<cr>
nnoremap <leader>g :silent gr <cword><cr>

nnoremap <leader>d :ALEGoToDefinition<CR>
nnoremap <leader>k :ALEHover<CR>

nnoremap <leader>aj :ALENext -error<cr>
nnoremap <leader>ak :ALEPrevious -error<cr>
nnoremap <leader>ac :ALECodeAction<CR>
vnoremap <leader>ac :ALECodeAction<CR>
nnoremap <leader>ar :ALERename<CR>
nnoremap <leader>af :ALEFindReferences<CR>

nnoremap <leader>l :call GetLastMessage()<cr>

nnoremap <leader>m :Maps<cr>

" window commands
nnoremap <leader>ww :wincmd w<CR>
nnoremap <leader>wc :wincmd c<CR>
nnoremap <leader>wo :wincmd o<CR>
nnoremap <leader>wh :wincmd h<CR>
nnoremap <leader>wj :wincmd j<CR>
nnoremap <leader>wk :wincmd k<CR>
nnoremap <leader>wl :wincmd l<CR>

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

function! SynStack ()
    for i1 in synstack(line("."), col("."))
        let i2 = synIDtrans(i1)
        let n1 = synIDattr(i1, "name")
        let n2 = synIDattr(i2, "name")
        echo n1 "->" n2
    endfor
endfunction

map gm :call SynStack()<CR>
