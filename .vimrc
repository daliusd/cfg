let g:python3_host_prog = expand('~').'/projects/tools/py3nvim/bin/python'

" UI part

if has('nvim')
  set clipboard+=unnamedplus
  noremap <C-s>     :update<CR>
  vnoremap <C-s>    <C-C>:update<CR>
  inoremap <C-s>    <Esc>:update<CR>gi

  cmap <C-v> <C-r>+
  imap <C-v> <C-r>+
  tnoremap <expr> <C-v> '<C-\><C-N>pi'

  vmap <C-c> y      " I dont' care about this one but let's have it

  set autoread
  au FocusGained * :checktime
endif

set mouse=a     " Enable mouse for everything

:syntax enable
set termguicolors
set background=light
set guioptions-=T " Hide toolbar
set guioptions-=m " Hide menu
set hidden " Allow opening new buffer without saving or opening it in new tab

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

set diffopt+=vertical " Vertical diff

let g:netrw_browsex_viewer="setsid xdg-open"    " Make gx command work properly with URLs in gvim

" We want string-like-this to be treated as word. That however means that proper spacing must
" be used in arithmetic operations.
:set iskeyword+=-
:set iskeyword-=$

" Indentation and Tab
set autoindent
set expandtab
set smarttab
"set sts=4      " Number of spaces per tab while editing
set sw=2        " Spaces per indent

au BufRead,BufNewFile *.py setlocal sw=4

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

" Command mode up/down remap
cnoremap <c-k> <up>
cnoremap <c-j> <down>

" Leader commands
let mapleader = ","

map <silent> <leader>n :silent noh<CR>
map <C-n> :cn<cr>
map <C-p> :cp<cr>
nmap <leader>p :let @+ = expand('%:p')<cr>
map <leader>e :e %:p:h<CR> " Open folder of current file
map <leader>cd :cd %:p:h<CR>:pwd<CR> " CD to current's file directory

map <leader>jf :%!python -m json.tool<cr>

" The 66-character line (counting both letters and spaces) is widely regarded as ideal.
" http://webtypography.net/Rhythm_and_Proportion/Horizontal_Motion/2.1.2/
au BufRead,BufNewFile *.md     setlocal textwidth=66
au BufRead,BufNewFile *.rst     setlocal textwidth=66

" Tab navigation
map <c-j> :tabnext<CR>
map <c-k> :tabprev<CR>
map <c-l> :tabm +1<CR>
map <c-g> :tabm -1<CR>


map tt :tabnew<CR>
map td :tabclose<CR>
map ta :tabnew<CR>
map ts :tab split<CR>
map to :tabonly<CR>

" Faster navigation through code
:set tags=./tags;

nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>

:set grepprg=rg\ --vimgrep\ -M\ 160\ -S\ --ignore-file\ ~/.gitignore_global

" Plugins

call plug#begin('~/.vim/plugged')

" Generic programming plugins
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'dense-analysis/ale'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'

Plug 'jamessan/vim-gnupg'
Plug 'danilamihailov/beacon.nvim'

if has('nvim')
  Plug 'Shougo/deoplete.nvim'
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

Plug 'editorconfig/editorconfig-vim'

" Plug 'SirVer/ultisnips'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'honza/vim-snippets'

Plug 'mgedmin/test-switcher.vim'

Plug 'tpope/vim-eunuch'

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
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
Plug 'elzr/vim-json'
Plug 'ruanyl/coverage.vim'
" Plug 'Galooshi/vim-import-js' # NOTE: Using vim-js-file-import instead

Plug 'kristijanhusak/vim-js-file-import', {'do': 'npm install'}
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

" Typescript
" NOTE: not using this as configuration below seems to be better.
" Plug 'Shougo/vimproc.vim', {'do' : 'make'}
" Plug 'Quramy/tsuquyomi'
Plug 'leafgarland/typescript-vim'
" Plug 'Quramy/vim-js-pretty-template'

" Plug 'HerringtonDarkholme/yats.vim'
" if has('nvim')
"   Plug 'mhartington/nvim-typescript', {'do': './install.sh'}
" endif

" Html
Plug 'valloric/MatchTagAlways'

" React
" Plug 'mxw/vim-jsx' <-- Stopped using because of conflict with
" deoplete-ternjs and autocomplete-flow.
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'wokalski/autocomplete-flow'

" Svelte
Plug 'evanleck/vim-svelte'
Plug 'Shougo/context_filetype.vim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Other
Plug 'junegunn/goyo.vim'
" Plug 'altercation/vim-colors-solarized'
Plug 'iCyMind/NeoSolarized'
Plug 'fszymanski/deoplete-emoji'
Plug 'deathlyfrantic/deoplete-spell'

call plug#end()

" Solarized
colorscheme NeoSolarized
highlight Comment cterm=italic
highlight Statement cterm=italic
highlight Type cterm=italic

" Goyo
function! s:goyo_enter()
    :set linebreak
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()

" Deoplete
let g:deoplete#enable_at_startup = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
imap <expr><TAB>
            \ pumvisible() ? "\<C-n>" :
            \ neosnippet#expandable_or_jumpable() ?
            \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

let g:deoplete#sources#jedi#show_docstring = 1

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_count = 0
let g:airline#extensions#tabline#show_tab_nr = 0

let g:airline_detect_spell=0


" Ale
"
"
let js_fixers = ['prettier', 'eslint']

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': js_fixers,
\   'javascript.jsx': js_fixers,
\   'typescript': js_fixers,
\   'typescriptreact': js_fixers,
\   'css': ['prettier'],
\   'json': ['prettier'],
\   'python': ['yapf', 'isort'],
\   'svelte': ['prettier', 'eslint'],
\}

let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 0
let g:airline#extensions#ale#enabled = 1
let g:ale_sign_column_always = 1
let g:ale_sign_error = "◉"
let g:ale_sign_warning = "◉"
highlight ALEErrorSign ctermfg=9 ctermbg=15 guifg=#C30500
highlight ALEWarningSign ctermfg=11 ctermbg=15 guifg=#ED6237

nmap <silent> <leader>aj :ALENext<cr>
nmap <silent> <leader>ak :ALEPrevious<cr>

command! ALEToggleFixer execute "let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1"

" UltiSnips
" let g:UltiSnipsExpandTrigger="<c-j>"

" neosnippet.vim
imap <C-j>     <Plug>(neosnippet_expand_or_jump)
smap <C-j>     <Plug>(neosnippet_expand_or_jump)
xmap <C-j>     <Plug>(neosnippet_expand_target)

let g:neosnippet#enable_snipmate_compatibility = 1

" My todo files
au BufRead,BufNewFile *.todo        set filetype=todo

" fzf
set rtp+=~/.fzf
let g:fzf_buffers_jump = 1
nnoremap <c-f> :Files<cr>
nnoremap <c-b> :Buffers<cr>
nnoremap <c-h> :History<cr>
nmap <leader>/ :BLines<cr>

command! -bang -nargs=* Rg
    \ call fzf#vim#grep("rg --vimgrep --smart-case \"".<q-args>."\"", 1,
    \                   <bang>0)

command! -bang -nargs=* Rgw
    \ call fzf#vim#grep("rg --vimgrep --smart-case -w ".shellescape(expand('<cword>')), 1,
    \                   <bang>0)

:cnoreabbrev rg Rg

map <leader>s :Rgw<cr>
map <leader>g :gr <cword><cr>

" jedi-vim
let g:jedi#completions_enabled = 0
let g:jedi#usages_command = "<leader>u"
let g:jedi#goto_stubs_command = "<leader>ss"

let g:jedi#goto_command = "<c-]>"
autocmd FileType python map <buffer> <leader>d g<c-]>

" pangloss/vim-javascript
let g:javascript_plugin_flow = 1

" vim-json
let g:vim_json_syntax_conceal = 0

" editorconfig-vim
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" coverage-highlight
map <leader>h :HighlightCoverage<cr>
map <leader>hh :HighlightCoverageOff<cr>

" mgedmin/python-imports.vim
autocmd FileType python map <buffer> <leader>i :ImportName<cr>

" Galooshi/vim-import-js
" autocmd FileType javascript map <buffer> <leader>f :ImportJSFix<cr>
" autocmd FileType javascript.jsx map <buffer> <leader>f :ImportJSFix<cr>
" autocmd FileType typescript map <buffer> <leader>f :ImportJSFix<cr>
" autocmd FileType typescript.tsx map <buffer> <leader>f :ImportJSFix<cr>
" autocmd FileType typescriptreact map <buffer> <leader>f :ImportJSFix<cr>

" coverage.vim
let g:coverage_json_report_path = 'coverage/coverage-final.json'

" test-switcher.vim
autocmd FileType python map <leader>t :SwitchCodeAndTest<CR>
autocmd FileType python map <leader>tt :e %:r.test.%:e<CR>

" React specific mappings
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

map <leader>jj :call SwitchToCodeFile()<cr>
map <leader>jt :call SwitchToTestFile()<cr>
map <leader>js :exe 'e ' . split(expand('%'), '\.')[0] . '.sass'<cr>
map <leader>jc :exe 'e ' . split(expand('%'), '\.')[0] . '.css'<cr>
map <leader>jm :exe 'e ' . split(expand('%'), '\.')[0] . '.module.css'<cr>
map <leader>jn :exe 'e ' . split(expand('%'), '\.')[0] . '.scss'<cr>


" typescript
" nvim-typescript
" autocmd FileType typescript map <buffer> <leader>i :TSImport<cr>
" autocmd FileType typescript.tsx map <buffer> <leader>i :TSImport<cr>
" NOTE: As well vim-js-file-import is in use here
let g:ale_completion_tsserver_autoimport = 1

" autocmd FileType typescript map <buffer> <leader>d g<c-]>
" autocmd FileType typescript.tsx map <buffer> <leader>d g<c-]>
"
" autocmd FileType typescript map <buffer> <c-]> :TSDef<cr>
" autocmd FileType typescript.tsx map <buffer> <c-]> :TSDef<cr>
" autocmd FileType typescript map <buffer> <c-]> :ALEGoToDefinition<cr>
" autocmd FileType typescriptreact map <buffer> <c-]> :ALEGoToDefinition<cr>

autocmd FileType javascript map <buffer> <leader>d g<c-]>
autocmd FileType typescript map <buffer> <leader>d g<c-]>
autocmd FileType typescriptreact map <buffer> <leader>d g<c-]>

autocmd FileType javascript map <buffer> <c-]> :call LanguageClient#textDocument_definition()<CR>
autocmd FileType typescript map <buffer> <c-]> :call LanguageClient#textDocument_definition()<CR>
autocmd FileType typescriptreact map <buffer> <c-]> :call LanguageClient#textDocument_definition()<CR>

" autocmd FileType typescript map <buffer> <leader>t :TSType<cr>
" autocmd FileType typescript.tsx map <buffer> <leader>t :TSType<cr>

" autocmd FileType typescript map <buffer> <leader>t :ALEHover<cr>
" autocmd FileType typescriptreact map <buffer> <leader>t :ALEHover<cr>

autocmd FileType javascript map <buffer> <leader>t :call LanguageClient#textDocument_hover()<CR>
autocmd FileType typescript map <buffer> <leader>t :call LanguageClient#textDocument_hover()<CR>
autocmd FileType typescriptreact map <buffer> <leader>t :call LanguageClient#textDocument_hover()<CR>

" autocmd FileType typescript map <buffer> <leader>x :TSGetCodeFix<cr>
" autocmd FileType typescript.tsx map <buffer> <leader>x :TSGetCodeFix<cr>

set noshowmode " This is shown by vim-airline already so I don't need NORMAL/INSERT/... in command line

" Svelte
if !exists('g:context_filetype#same_filetypes')
    let g:context_filetype#filetypes = {}
endif
let g:context_filetype#filetypes.svelte =
            \ [
            \    {'filetype' : 'javascript', 'start' : '<script>', 'end' : '</script>'},
            \    {'filetype' : 'css', 'start' : '<style>', 'end' : '</style>'},
            \ ]

call deoplete#custom#var('omni', 'functions', {
\ 'css': ['csscomplete#CompleteCSS']
\})

" NERD tree
map <leader>b :NERDTreeToggle<CR>
map <leader>v :NERDTreeFind<CR>
let g:NERDTreeMapJumpNextSibling = ''
let g:NERDTreeMapJumpPrevSibling = ''

let g:LanguageClient_serverCommands = {
    \ 'javascript': ['typescript-language-server', '--stdio'],
    \ 'typescript': ['typescript-language-server', '--stdio'],
    \ 'typescriptreact': ['typescript-language-server', '--stdio'],
    \ 'html': ['html-languageserver', '--stdio'],
    \ 'css': ['css-languageserver', '--stdio'],
    \ 'json': ['json-languageserver', '--stdio'],
    \ 'svelte': ['svelteserver', '--stdio'],
    \ }

nnoremap <silent> <leader>ca :call LanguageClient#textDocument_codeAction()<CR>

let g:LanguageClient_diagnosticsList='Disabled'

" gutentags
let g:gutentags_project_root = ['package.json']
let g:gutentags_add_default_project_roots = 0
let g:gutentags_exclude_filetypes = ['gitcommit', 'gitrebase']

" beacon
highlight Beacon guibg=black ctermbg=0
