-- Commands

-- format/unformat

vim.api.nvim_create_user_command(
  'FormatJSON',
  function()
    vim.cmd('%!python3 -m json.tool')
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'UnformatJSON',
  function()
    vim.cmd(':%!node ~/bin/unjson.js')
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatSHTOUT',
  function()
    vim.cmd(":%!node ~/bin/sht.js")
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'UnformatSHTOUT',
  function()
    vim.cmd(":%!node ~/bin/usht.js")
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatHtml',
  function()
    vim.cmd("%!tidy -q -i --show-errors 0")
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatXml',
  function()
    vim.cmd("%!tidy -q -i --show-errors 0 -xml")
  end,
  {}
)

vim.api.nvim_create_user_command(
  'Rg',
  function(args)
    require("fzf-lua").live_grep_glob({ search = args['args'] })
  end,
  { nargs = '*' }
)

vim.cmd(":cnoreabbrev <expr> rg (getcmdtype() == ':' && getcmdline() ==# 'rg') ? 'Rg' : 'rg'")

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
