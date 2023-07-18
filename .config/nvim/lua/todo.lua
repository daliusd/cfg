vim.api.nvim_create_autocmd(
  { 'BufRead', 'BufNewFile' },
  { pattern = '*.todo', command = 'setlocal filetype=todo' }
)

vim.api.nvim_create_autocmd(
  { 'BufRead', 'BufNewFile' },
  { pattern = '*.todo', command = 'setlocal foldmethod=indent' }
)
