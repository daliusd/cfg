-- Commands

-- format/unformat

vim.api.nvim_create_user_command('FormatJSON', function()
  vim.cmd('%!python3 -m json.tool')
  vim.bo.filetype = 'json'
end, {})

vim.api.nvim_create_user_command('UnformatJSON', function()
  vim.cmd(':%!node ~/bin/unjson.js')
  vim.bo.filetype = 'json'
end, {})

vim.api.nvim_create_user_command('FormatSHTOUT', function()
  vim.cmd(':%!node ~/bin/sht.js')
  vim.bo.filetype = 'json'
end, {})

vim.api.nvim_create_user_command('UnformatSHTOUT', function()
  vim.cmd(':%!node ~/bin/usht.js')
  vim.bo.filetype = 'json'
end, {})

vim.api.nvim_create_user_command('FormatHtml', function()
  if vim.fn.executable('npx') == 1 then
    vim.cmd('%!npx prettier --parser html')
    vim.bo.filetype = 'html'
  else
    vim.notify('npx is not available', vim.log.levels.ERROR)
  end
end, {})

vim.api.nvim_create_user_command('FormatXml', function()
  if vim.fn.executable('npx') == 1 then
    vim.cmd('%!npx -y prettier --parser xml --plugin=@prettier/plugin-xml')
    vim.bo.filetype = 'xml'
  else
    vim.notify('npx is not available', vim.log.levels.ERROR)
  end
end, {})

vim.api.nvim_create_user_command('Rg', function(args)
  require('fzf-lua').live_grep_glob({ search = args['args'] })
end, { nargs = '*' })

vim.cmd(":cnoreabbrev <expr> rg (getcmdtype() == ':' && getcmdline() ==# 'rg') ? 'Rg' : 'rg'")

-- Copy GitHub URL to clipboard
vim.api.nvim_create_user_command('GithubCopyUrl', function(opts)
  -- Get the remote URL
  local remote_url = vim.fn.system('git config --get remote.origin.url'):gsub('%s+', '')

  -- Convert SSH/HTTPS URL to web URL
  local web_url = remote_url:gsub('git@github%.com:', 'https://github.com/'):gsub('%.git$', '')

  -- Get current file path relative to repo root
  local git_root = vim.fn.system('git rev-parse --show-toplevel'):gsub('%s+', '')
  local file_path = vim.fn.expand('%:p')
  local relative_path = file_path:gsub('^' .. vim.pesc(git_root) .. '/', '')

  -- Get current branch
  local branch = vim.fn.system('git rev-parse --abbrev-ref HEAD'):gsub('%s+', '')

  -- Get line numbers from range
  local line_start = opts.line1
  local line_end = opts.line2

  -- Build URL
  local url = string.format('%s/blob/%s/%s#L%d', web_url, branch, relative_path, line_start)
  if line_end ~= line_start then
    url = url .. '-L' .. line_end
  end

  -- Copy to clipboard
  vim.fn.setreg('+', url)
  print('Copied: ' .. url)
end, { range = true })

-- vim.api.nvim_create_user_command(
--   'TSRemoveUnusedImports',
--   function()
--     ---@diagnostic disable-next-line: assign-type-mismatch
--     vim.lsp.buf.code_action({ apply = true, context = { only = { "source.removeUnusedImports.ts" }, diagnostics = {} } })
--   end,
--   {}
-- )
--
-- vim.api.nvim_create_user_command(
--   'TSRemoveUnused',
--   function()
--     ---@diagnostic disable-next-line: assign-type-mismatch
--     vim.lsp.buf.code_action({ apply = true, context = { only = { "source.removeUnused.ts" }, diagnostics = {} } })
--   end,
--   {}
-- )
--
-- vim.api.nvim_create_user_command(
--   'TSAddMissingImports',
--   function()
--     ---@diagnostic disable-next-line: assign-type-mismatch
--     vim.lsp.buf.code_action({ apply = true, context = { only = { "source.addMissingImports.ts" }, diagnostics = {} } })
--   end,
--   {}
-- )
