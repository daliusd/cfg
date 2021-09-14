let g:python3_host_prog = expand('~').'/projects/soft/py3nvim/bin/python'

" UI part

if has('nvim')
  set clipboard+=unnamedplus
  noremap <C-s>     :update<CR>
  vnoremap <C-s>    <C-C>:update<CR>
  inoremap <C-s>    <Esc>:update<CR>gi

  cnoremap <C-v> <C-r>+
  inoremap <C-v> <C-r>+
  tnoremap <expr> <C-v> '<C-\><C-N>pi'

  set autoread
  au FocusGained * :checktime
endif

set mouse=a     " Enable mouse for everything

syntax spell toplevel
syntax enable
set termguicolors
set background=light
set guioptions-=T " Hide toolbar
set guioptions-=m " Hide menu
set hidden " Allow opening new buffer without saving or opening it in new tab
set noshowmode " This is shown by vim-airline already so I don't need NORMAL/INSERT/... in command line

set wildmenu    " better command-line completion
set list listchars=trail:.,tab:>- " Show trailing dots and tabs

set scrolloff=3     " Keep 3 lines below and above the cursor
set number          " Show line numbering
set numberwidth=1   " Use 1 col + 1 space for numbers

set synmaxcol=500   " should make slightly faster than 3000

" Vim stuff
set nocp        " Makes VIM more useful
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

" Tree-sitter based folding
set foldmethod=indent " syntax folding method makes prettier fixer slower
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()

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

" Leader commands
let mapleader = ","

function! FormatJSON()
  exe '%!python -m json.tool'
  set filetype=json
endfunction

command FormatJSON call FormatJSON()

function! FormatSHTOUT()
  exe ':%!node ~/sht.js'
  set filetype=json
endfunction

command FormatSHTOUT call FormatSHTOUT()

function! UnformatSHTOUT()
  exe ':%!node ~/usht.js'
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
nnoremap tj :tabnext<CR>
nnoremap tk :tabprev<CR>
nnoremap tl :tabm +1<CR>
nnoremap th :tabm -1<CR>

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
:set grepprg=rg\ --vimgrep\ -M\ 160\ -S\ --ignore-file\ ~/.gitignore_global

" Plugins

call plug#begin('~/.vim/plugged')

" Generic programming plugins
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'will133/vim-dirdiff'

Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'tmsvg/pear-tree'

Plug 'dense-analysis/ale'
" Plug '~/projects/ale'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'Shougo/deoplete.nvim'
Plug 'fszymanski/deoplete-emoji'
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
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Other
Plug 'cormacrelf/vim-colors-github'

Plug 'gko/vim-coloresque'

call plug#end()

" Colors
colorscheme github

let g:markdown_fenced_languages = ['css', 'javascript', 'json']

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
let g:airline#extensions#ale#enabled = 1
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = "🔥 "
let g:ale_sign_column_always = 1
let g:ale_completion_autoimport = 1
let g:ale_lsp_suggestions = 1
let g:ale_floating_preview = 1

let g:ale_sign_error = "🐛"
let g:ale_sign_warning = "⚠️"
let g:ale_sign_info = "ℹ"

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

call deoplete#custom#source('emoji', 'converters', ['converter_emoji'])
call deoplete#custom#var('buffer', 'require_same_filetype', v:false)

set completeopt-=preview
let g:float_preview#docked = 0

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_count = 0
let g:airline#extensions#tabline#show_tab_nr = 0

let g:airline_powerline_fonts = 1
let g:airline_detect_spell=0
"let g:airline_theme='solarized'
"let g:airline_theme='pencil'
let g:airline_theme='github'
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

let g:airline_mode_map = {
    \ '__'     : '-',
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'ic'     : 'I',
    \ 'ix'     : 'I',
    \ 'n'      : 'N',
    \ 'multi'  : 'M',
    \ 'ni'     : 'N',
    \ 'no'     : 'N',
    \ 'R'      : 'R',
    \ 'Rv'     : 'R',
    \ 's'      : 'S',
    \ 'S'      : 'S',
    \ ''     : 'S',
    \ 't'      : 'T',
    \ 'v'      : 'V',
    \ 'V'      : 'V',
    \ ''     : 'V',
    \ }


" My todo files
au BufRead,BufNewFile *.todo        setlocal filetype=todo
au BufRead,BufNewFile *.todo        setlocal foldmethod=indent

" fzf
set rtp+=~/.fzf
let g:fzf_buffers_jump = 1
let g:fzf_layout = { 'window' : { 'width': 1, 'height': 0.8, 'highlight': 'Normal' } }

command! -bang -nargs=* Rgw
    \ call fzf#vim#grep("rg --vimgrep --smart-case -w ".shellescape(expand('<cword>')), 1,
    \                   fzf#vim#with_preview(),
    \                   <bang>0)

:cnoreabbrev rg Rg


" editorconfig-vim
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" coverage.vim
let g:coverage_json_report_path = 'coverage/coverage-final.json'

" Javascript specific mappings
function! SwitchToCodeFile()
    let fn = split(expand('%'), '\.')[0]
    if filereadable(fn.'.js')
        exe 'e ' . fn . '.js'
    elseif filereadable(fn.'.ts')
        exe 'e ' . fn . '.ts'
    elseif filereadable(fn.'.tsx')
        exe 'e ' . fn . '.tsx'
    endif
endfunction

function! SwitchToTestFile()
    let spl = split(expand('%'), '\.')
    let fn = spl[0]
    let ext = spl[len(spl)-1]

    if filereadable(fn . '.test.' . ext)
        exe 'e ' . fn . '.test.' . ext
    elseif filereadable(fn . '.spec.' . ext)
        exe 'e ' . fn . '.spec.' . ext
    elseif filereadable(fn . '.it.' . ext)
        exe 'e ' . fn . '.it.' . ext
    else
        exe 'e ' . fn . '.spec.' . ext
    endif
endfunction

function! SwitchToStyleFile()
    let fn = split(expand('%'), '\.')[0]
    if filereadable(fn.'.sass')
        exe 'e ' . fn . '.sass'
    elseif filereadable(fn.'.css')
        exe 'e ' . fn . '.css'
    elseif filereadable(fn.'.scss')
        exe 'e ' . fn . '.scss'
    elseif filereadable(fn.'.module.css')
        exe 'e ' . fn . '.module.css'
    endif
endfunction

function! GetLastMessage()
  execute ":redir @+"
  execute ":1messages"
  execute ":redir END"
endfunction

function! OpenFailingTest()
  let lastFile = system("tmux select-pane -L && tmux capture-pane -pJ -S - | rg -o '[[:alnum:]_.$&+=/@-]*:[0-9]*:[0-9]*' | tail -n 1 && tmux select-pane -R")
  let path = split(lastFile, ':')
  if filereadable(path[0])
    exe 'e ' . path[0]
    call cursor(str2nr(path[1]), str2nr(path[2]))
  else
    echo "File not found: " . lastFile
  endif
endfunction

" Fugitive
:cnoreabbrev gps Git push
:cnoreabbrev gpl Git pull

" gitgutter
let g:gitgutter_map_keys = 0

" tree-sitter
" lua <<EOF
" require'nvim-treesitter.configs'.setup {
"   ensure_installed = "all",     -- one of "all", "language", or a list of languages
"   highlight = {
"     enable = true,              -- false will disable the whole extension
"   },
" }
" EOF

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

nnoremap <leader>, :
nnoremap <leader>o <c-o>
nnoremap <silent> <leader>n :silent noh<CR>
nnoremap <leader>z :w<CR>
nnoremap <leader>q :qa<CR>

nnoremap <leader>pf :let @+ = expand('%:p')<cr>
nnoremap <leader>pp :let @+ = expand('%')<cr>
nnoremap <leader>pn :let @+ = expand('%:t')<cr>

nnoremap <leader>c :Commands<cr>

nnoremap <leader>id "=strftime("%Y-%m-%d ")<CR>P

nnoremap <leader>h :History<cr>
nnoremap <leader>f :Files<cr>
nnoremap <leader>s :Rgw<cr>
nnoremap <leader>g :gr <cword><cr>

nnoremap <leader>d :ALEGoToDefinition<CR>
nnoremap <leader>k :ALEHover<CR>

nnoremap <leader>aj :ALENext -error<cr>
nnoremap <leader>ak :ALEPrevious -error<cr>
nnoremap <leader>ac :ALECodeAction<CR>
vnoremap <leader>ac :ALECodeAction<CR>
nnoremap <leader>ar :ALERename<CR>
nnoremap <leader>af :ALEFindReferences<CR>

nnoremap <leader>jj :call SwitchToCodeFile()<cr>
nnoremap <leader>jt :call SwitchToTestFile()<cr>
nnoremap <leader>js :call SwitchToStyleFile()<cr>

nnoremap <leader>l :call GetLastMessage()<cr>

nnoremap <leader>m :Maps<cr>

nnoremap <leader>t :call OpenFailingTest()<cr>

" window commands
nnoremap <leader>wc :wincmd c<CR>
nnoremap <leader>wo :wincmd o<CR>
nnoremap <leader>wh :wincmd h<CR>
nnoremap <leader>wj :wincmd j<CR>
nnoremap <leader>wk :wincmd k<CR>
nnoremap <leader>wl :wincmd l<CR>

" vimrc file
nnoremap <leader>v :e ~/.vimrc<cr>
