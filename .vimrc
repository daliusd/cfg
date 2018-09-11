" Copy Paste using Ctrl+C, Ctrl+V
source $VIMRUNTIME/mswin.vim
behave mswin

set nobackup
set nowritebackup
set directory=/tmp
set undodir=/tmp

set autoindent
set expandtab
set sts=4
set sw=4
set tabstop=4
set bs=2
set nofixeol    " Let's not fix end-of-line
set fileencodings=utf-8,ucs-bom,latin1
set encoding=utf-8
set hlsearch
set incsearch
set mouse=a
set nocp    " Makes VIM more useful
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

"noremap j gj
"noremap k gk
noremap ; :

"map <silent> <up> gk
"imap <silent> <up> <C-o>gk
"map <silent> <down> gj
"imap <silent> <down> <C-o>gj
"map <silent> <home> g<home>
"imap <silent> <home> <C-o>g<home>
"map <silent> <end> g<end>
"imap <silent> <end> <C-o>g<end>
imap jj <ESC>j
set spell
set spelllang=en,lt

let mapleader = ","

map <silent> <leader>n :silent noh<CR>
map <C-n> :cn<cr>
map <C-m> :cp<cr>
nmap <leader>p :let @+ = expand('%:p')<cr>

map <leader>js :%!python -m json.tool<cr>
map <leader>d i<C-R>=strftime("%Y-%m-%d")<CR><Esc>

au BufRead,BufNewFile *.todo        set filetype=todo

" The 66-character line (counting both letters and spaces) is widely regarded as ideal.
" http://webtypography.net/Rhythm_and_Proportion/Horizontal_Motion/2.1.2/
au BufRead,BufNewFile *.md     setlocal textwidth=66
au BufRead,BufNewFile *.rst     setlocal textwidth=66
au BufRead,BufNewFile *.todo    setlocal textwidth=66

map <C-Left> :tabprev<CR>
map <C-Right> :tabnext<CR>
map <C-S-Left> :tabm -1<CR>
map <C-S-Right> :tabm +1<CR>
nnoremap tt :tabedit<Space>
nnoremap td :tabclose<CR>
nnoremap ta :tabnew<CR>
nnoremap tc :tabedit %<CR>
"map <C-W> :tabclose<cr>

:set tags=./tags;
:set grepprg=rg\ --vimgrep\ -M\ 160
map <leader>s :gr <cword><cr>


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
let g:ale_open_list = 1
