# Home folder configuration

Initial run requires following commands:

```console
# Clone this repo
git clone --bare git@github.com:daliusd/cfg.git .cfg

# Alias cfg properly
alias cfg='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Do initial config repository configuration and checkout
cfg config --local status.showUntrackedFiles no
cfg checkout

# Run initialization.
./init.sh
```

## Git

Check for instructions: https://github.com/ewanmellor/git-diff-image

## Vim notes

You will need to run ":set spell" to download spell files.

### Vim LSP clients and other solutions I have tried to use

Currently I use Ale + Deoplete. See [.vimrc](./.vimrc) for details.

#### CoC

Overall I found CoC quite easy to configure and use however
sometimes unnecessary slow. E.g. switching tabs takes more than
one second.

Plug:

```vimrc
Plug 'neoclide/coc.nvim', {'branch': 'release'}"
```

Config:

```vimrc
let g:coc_global_extensions = [
\ 'coc-css',
\ 'coc-emoji',
\ 'coc-eslint',
\ 'coc-html',
\ 'coc-json',
\ 'coc-prettier',
\ 'coc-python',
\ 'coc-tsserver',
\ 'coc-explorer',
\ 'coc-markdownlint',
\ 'coc-vimlsp',
\ 'coc-word'
\ ]

inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

nmap <silent> <leader>aj <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>ak <Plug>(coc-diagnostic-next)

nmap <silent> <c-]> <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)

nmap <leader>rn <Plug>(coc-rename)

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

nmap <leader>qf  <Plug>(coc-fix-current)

autocmd CursorHold * silent call CocActionAsync('highlight')

command! -nargs=0 Tsc :call CocAction('runCommand', 'tsserver.watchBuild')

nnoremap <leader>e :CocCommand explorer<CR>
```

#### NeoVim LSP

Overall NeoVim LSP feels quite snappy and good but it requires too
much configuration as of today (2020-10-30). As well it crashed
the whole editor for me at least twice during the week.

Plug:

```vimrc
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'nvim-lua/diagnostic-nvim'
```

Config:

```vimrc
lua <<EOF

local on_attach = function(_, bufnr)
  require'diagnostic'.on_attach()
  require'completion'.on_attach()
end

require'nvim_lsp'.tsserver.setup{}
require'nvim_lsp'.tsserver.setup{on_attach=on_attach}
require'nvim_lsp'.cssls.setup{}
require'nvim_lsp'.cssls.setup{on_attach=on_attach}
require'nvim_lsp'.html.setup{}
require'nvim_lsp'.html.setup{on_attach=on_attach}
require'nvim_lsp'.jsonls.setup{}
require'nvim_lsp'.jsonls.setup{on_attach=on_attach}
EOF

nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <leader>qf     <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>rn     <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <leader>ld     <cmd>lua vim.lsp.util.show_line_diagnostics()<CR>

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <C-j>   pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <C-k>   pumvisible() ? "\<C-p>" : "\<C-k>"

nnoremap <silent> <leader>aj :PrevDiagnosticCycle<CR>
nnoremap <silent> <leader>ak :NextDiagnosticCycle<CR>

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

let g:diagnostic_enable_virtual_text = 1
let g:diagnostic_virtual_text_prefix = ' '
let g:diagnostic_insert_delay = 1

call sign_define("LspDiagnosticsErrorSign", {"text" : "➤", "texthl" : "LspDiagnosticsError"})
call sign_define("LspDiagnosticsWarningSign", {"text" : "➤", "texthl" : "LspDiagnosticsWarning"})
call sign_define("LspDiagnosticsInformationSign", {"text" : "↬", "texthl" : "LspDiagnosticsInformation"})
call sign_define("LspDiagnosticsHintSign", {"text" : "↬", "texthl" : "LspDiagnosticsHint"})
```

#### LanguageClient-neovim

Quite stable but I simply stopped using it.

Plug:

```vimrc
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
```

Config:

```vimrc
autocmd FileType javascript map <buffer> <c-]> :call LanguageClient#textDocument_definition()<CR>
autocmd FileType typescript map <buffer> <c-]> :call LanguageClient#textDocument_definition()<CR>
autocmd FileType typescriptreact map <buffer> <c-]> :call LanguageClient#textDocument_definition()<CR>

autocmd FileType javascript map <buffer> <leader>t :call LanguageClient#textDocument_hover()<CR>
autocmd FileType typescript map <buffer> <leader>t :call LanguageClient#textDocument_hover()<CR>
autocmd FileType typescriptreact map <buffer> <leader>t :call LanguageClient#textDocument_hover()<CR>

nnoremap <silent> <leader>ca :call LanguageClient#textDocument_codeAction()<CR>

let g:LanguageClient_serverCommands = {
    \ 'javascript': ['typescript-language-server', '--stdio'],
    \ 'typescript': ['typescript-language-server', '--stdio'],
    \ 'typescriptreact': ['typescript-language-server', '--stdio'],
    \ 'html': ['html-languageserver', '--stdio'],
    \ 'css': ['css-languageserver', '--stdio'],
    \ 'json': ['json-languageserver', '--stdio'],
    \ 'svelte': ['svelteserver', '--stdio'],
    \ }

let g:LanguageClient_diagnosticsList='Disabled'
```
