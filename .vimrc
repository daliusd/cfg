" UI part
"   Copy Paste using Ctrl+C, Ctrl+V
if has("gui_running")
    source $VIMRUNTIME/mswin.vim
    behave mswin
endif

set mouse=a     " Enable mouse for everything

:syntax enable
if has("gui_running")
    set background=light
else
    set background=dark
endif
set guioptions-=T " Hide toolbar
set guioptions-=m " Hide menu

set wildmenu    " better command-line completion
set list listchars=trail:.,tab:>- " Show trailing dots and tabs

set scrolloff=3     " Keep 3 lines below and above the cursor
set number          " Show line numbering
set numberwidth=1   " Use 1 col + 1 space for numbers

" Vim stuff
set nocp        " Makes VIM more useful
set nofixeol    " Let's not fix end-of-line

set nobackup
set nowritebackup
set directory=/tmp
set undofile
set undodir=/tmp

set diffopt+=vertical " Vertical diff

let g:netrw_browsex_viewer="setsid xdg-open"    " Make gx command work properly with URLs in gvim

" We want string-like-this to be treated as word. That however means that proper spacing must
" be used in arithmetic operations.
:set iskeyword+=-

" Indentation and Tab
set autoindent
set expandtab
set smarttab
"set sts=4      " Number of spaces per tab while editing
set sw=4        " Spaces per indent

" FIXME: no decision yet
" au BufRead,BufNewFile *.html setlocal sw=2
" au BufRead,BufNewFile *.js setlocal sw=2

set tabstop=4   " Number of spaces per tab. People usually use 4, but they shouldn't use tab in the first place.
set bs=2        " same as ":set backspace=indent,eol,start"

set foldmethod=indent
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


" Some little keyboard goods
noremap ; :
imap jj <ESC>j

" Better navigation for wrapped lines.
noremap j gj
noremap k gk
map <silent> <up> gk
imap <silent> <up> <C-o>gk
map <silent> <down> gj
imap <silent> <down> <C-o>gj
map <silent> <home> g<home>
imap <silent> <home> <C-o>g<home>
map <silent> <end> g<end>
imap <silent> <end> <C-o>g<end>

" Leader commands
let mapleader = ","

map <silent> <leader>n :silent noh<CR>
map <C-n> :cn<cr>
map <C-m> :cp<cr>
nmap <leader>p :let @+ = expand('%:p')<cr>

map <leader>js :%!python -m json.tool<cr>
map <leader>i :ImportName<cr>

command Greview :Git! diff --staged
nnoremap <leader>gr :Greview<cr>

" The 66-character line (counting both letters and spaces) is widely regarded as ideal.
" http://webtypography.net/Rhythm_and_Proportion/Horizontal_Motion/2.1.2/
au BufRead,BufNewFile *.md     setlocal textwidth=66
au BufRead,BufNewFile *.rst     setlocal textwidth=66

" Tab navigation
map <c-j> :tabnext<CR>
map <c-k> :tabprev<CR>
map <c-a-j> :tabm +1<CR>
map <c-a-k> :tabm -1<CR>

map tt :tabedit<Space>
map td :tabclose<CR>
map <a-w> :tabclose<CR>
map ta :tabnew<CR>
map ts :tab split<CR>

" Faster navigation through code
:set tags=./tags;

nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>

:set grepprg=rg\ --vimgrep\ -M\ 160

" Plugins

call plug#begin('~/.vim/plugged')

" Generic programming plugins
Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'w0rp/ale'

Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'

Plug 'editorconfig/editorconfig-vim'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Python
Plug 'zchee/deoplete-jedi'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'davidhalter/jedi-vim'
Plug 'mgedmin/python-imports.vim'
Plug 'mgedmin/coverage-highlight.vim'

" Javascript
Plug 'pangloss/vim-javascript'
Plug 'carlitux/deoplete-ternjs' " Run: npm install -g tern
Plug 'ternjs/tern_for_vim'
Plug 'elzr/vim-json'

" React
Plug 'mxw/vim-jsx'
Plug 'epilande/vim-react-snippets'
Plug 'epilande/vim-es2015-snippets'
Plug 'wokalski/autocomplete-flow'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Other
Plug 'junegunn/goyo.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'fszymanski/deoplete-emoji'

call plug#end()

" Solarized
colorscheme solarized

" Goyo
function! s:goyo_enter()
    :set linebreak
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()

" Deoplete
let g:deoplete#enable_at_startup = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

let g:deoplete#sources#jedi#show_docstring = 1

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0

" Ale
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier', 'eslint'],
\   'css': ['prettier'],
\   'json': ['prettier'],
\   'python': ['yapf', 'isort'],
\}

let g:ale_fix_on_save = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_open_list = 1
let g:ale_sign_column_always = 1
let g:ale_sign_error = "◉"
let g:ale_sign_warning = "◉"
highlight ALEErrorSign ctermfg=9 ctermbg=15 guifg=#C30500
highlight ALEWarningSign ctermfg=11 ctermbg=15 guifg=#ED6237

" UltiSnips
let g:UltiSnipsExpandTrigger="<c-j>"

" My todo files
au BufRead,BufNewFile *.todo        set filetype=todo

" fzf
set rtp+=~/.fzf
let g:fzf_buffers_jump = 1
map <c-p> :Files<cr>
map <c-b> :Windows<cr>
map <c-h> :History<cr>

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Rg
    \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
    \                   fzf#vim#with_preview(),
    \                   <bang>0)

command! -bang -nargs=* Rgn
    \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, 1,
    \                   fzf#vim#with_preview(),
    \                   <bang>0)

command! -bang -nargs=* Rgw
    \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -w ".shellescape(expand('<cword>')), 1,
    \                   fzf#vim#with_preview(),
    \                   <bang>0)

map <leader>s :Rgw<cr>

" jedi-vim
let g:jedi#completions_enabled = 0
let g:jedi#usages_command = "<leader>u"

let g:jedi#goto_command = "<c-]>"
autocmd FileType python map <buffer> <leader>d g<c-]>

" Use tern_for_vim.
let g:tern#command = ["tern"]
let g:tern#arguments = ["--persistent"]

" editorconfig-vim
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" coverage-highlight
map <leader>h :HighlightCoverage<cr>
map <leader>hh :HighlightCoverageOff<cr>
