" Copy Paste using Ctrl+C, Ctrl+V
if has("gui_running")
    source $VIMRUNTIME/mswin.vim
    behave mswin
endif

set nobackup
set nowritebackup
set undofile
set directory=/tmp
set undodir=/tmp

set autoindent
set expandtab
set smarttab
"set sts=4      " Number of spaces per tab while editing
set sw=4        " Spaces per indent

au BufRead,BufNewFile *.html setlocal sw=2
au BufRead,BufNewFile *.js setlocal sw=2

set tabstop=8   " Number of spaces per file
set bs=2        " same as ":set backspace=indent,eol,start"
set nofixeol    " Let's not fix end-of-line
set fileencodings=utf-8,ucs-bom,latin1
set encoding=utf-8
set hlsearch    " Highlight search
set incsearch   " Show search as you type
set mouse=a     " Enable mouse for everything
set nocp        " Makes VIM more useful
set wildmenu    " better command-line completion
set list listchars=trail:.,tab:>-
:syntax enable
colorscheme solarized
if has("gui_running")
    set background=light
else
    set background=dark
endif
set guioptions-=T
set guioptions-=m
set ignorecase
set foldmethod=indent
set foldlevelstart=99
filetype plugin indent on
set scrolloff=3     " Keep 3 lines below and above the cursor
set number          " Show line numbering
set numberwidth=1   " Use 1 col + 1 space for numbers

noremap ; :

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

imap jj <ESC>j
set spell
set spelllang=en,lt

let mapleader = ","

map <silent> <leader>n :silent noh<CR>
map <C-n> :cn<cr>
map <C-m> :cp<cr>
nmap <leader>p :let @+ = expand('%:p')<cr>

map <leader>js :%!python -m json.tool<cr>

au BufRead,BufNewFile *.todo        set filetype=todo

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

" Ale
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\}

let g:ale_fix_on_save = 1

" Isort
let g:vim_isort_map = '' " Removing as this conflicts with UltiSnips somehow
