-- Commands

vim.api.nvim_create_user_command(
  'YoshiTest',
  function()
    vim.g['test#javascript#runner'] = 'jest'
    vim.g['test#javascript#jest#executable'] = 'yarn yoshi test'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'YoshiLibraryTest',
  function()
    vim.g['test#javascript#runner'] = 'jest'
    vim.g['test#javascript#jest#executable'] = 'yarn yoshi-library test'
  end,
  {}
)

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

local function extract_message()
  local s_buf, s_row, s_col, _ = unpack(vim.fn.getpos("v"))
  local _, e_row, e_col, _ = unpack(vim.fn.getpos("."))

  local value = vim.api.nvim_buf_get_text(s_buf, s_row - 1, s_col - 1, e_row - 1, e_col, {})[1]
  value = value:gsub('"', '\\"')

  local key = vim.fn.input("Key: ", "")
  if #key == 0 then
    return
  end

  key = key:gsub('"', '\\"')
  local tr_key = 't("' .. key .. '")'
  vim.api.nvim_buf_set_text(s_buf, s_row - 1, s_col - 1, e_row - 1, e_col, { tr_key })

  local out_file = vim.fn.system('fd messages_en.json')
  out_file = out_file:gsub("[\n]", "")
  local message_file_lines = vim.fn.readfile(out_file)
  message_file_lines[#message_file_lines - 1] = message_file_lines[#message_file_lines - 1] .. ','
  table.insert(message_file_lines, #message_file_lines, '  ' .. '"' .. key .. '": "' .. value .. '"')

  vim.fn.writefile(message_file_lines, out_file)

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'x', false)
end

vim.keymap.set('v', '<leader>z', extract_message, { noremap = true, silent = true })
