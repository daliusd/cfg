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

set diffopt+=iwhite " Ignore spaces in diff

let g:netrw_browsex_viewer="setsid xdg-open"    " Make gx command work properly with URLs in gvim

" Indentation and Tab
set autoindent
set expandtab
set smarttab
"set sts=4      " Number of spaces per tab while editing
set sw=4        " Spaces per indent

au BufRead,BufNewFile *.html setlocal sw=2
au BufRead,BufNewFile *.js setlocal sw=2

set tabstop=8   " Number of spaces per file
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

" The 66-character line (counting both letters and spaces) is widely regarded as ideal.
" http://webtypography.net/Rhythm_and_Proportion/Horizontal_Motion/2.1.2/
au BufRead,BufNewFile *.md     setlocal textwidth=66
au BufRead,BufNewFile *.rst     setlocal textwidth=66
au BufRead,BufNewFile *.todo    setlocal textwidth=66

" Tab navigation
map <C-Left> :tabprev<CR>
map <C-Right> :tabnext<CR>
map <C-S-Left> :tabm -1<CR>
map <C-S-Right> :tabm +1<CR>
nnoremap tt :tabedit<Space>
nnoremap td :tabclose<CR>
nnoremap ta :tabnew<CR>
nnoremap tc :tabedit %<CR>

" Faster navigation through code
:set tags=./tags;
:set grepprg=rg\ --vimgrep\ -M\ 160
map <leader>s :gr <cword><cr>

" Plugins

call plug#begin('~/.vim/plugged')

Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'pangloss/vim-javascript'
Plug 'zchee/deoplete-jedi'
Plug 'junegunn/goyo.vim'
Plug 'vim-airline/vim-airline'
Plug 'altercation/vim-colors-solarized'
Plug 'tpope/vim-fugitive'
Plug 'ludovicchabant/vim-gutentags'
Plug 'fisadev/vim-isort'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'w0rp/ale'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'carlitux/deoplete-ternjs'
Plug 'ternjs/tern_for_vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/fzf.vim'

call plug#end()

" Solarized
colorscheme solarized

" Goyo
function! s:goyo_enter()
    :set linebreak
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()

" ctrl-p
let g:ctrlp_custom_ignore = 'node_modules'

" Deoplete
let g:deoplete#enable_at_startup = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Ale
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\}

let g:ale_fix_on_save = 1
let g:airline#extensions#ale#enabled = 1

" Isort
let g:vim_isort_map = '' " Removing as this conflicts with UltiSnips somehow
:autocmd BufWritePre *.py :Isort

" UltiSnips
let g:UltiSnipsExpandTrigger="<c-j>"

" My todo files
au BufRead,BufNewFile *.todo        set filetype=todo

" fzf
set rtp+=~/.fzf
let g:fzf_buffers_jump = 1
map <c-p> :Files<cr>
map <c-b> :Windows<cr>

command!      -bang -nargs=* Rgn call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, 1, <bang>0)
