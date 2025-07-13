-- Keymaps

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap('n', ';', ':', { noremap = true })

-- Better navigation for wrapped lines.
keymap('n', 'j', 'gj', opts)
keymap('n', 'k', 'gk', opts)
keymap('n', '<down>', 'gj', opts)
keymap('i', '<down>', '<c-o>gj', opts)
keymap('n', '<up>', 'gk', opts)
keymap('i', '<up>', '<c-o>gk', opts)

-- q remapped to Q to avoid accidental macro mode
keymap('n', 'Q', 'q', opts)
keymap('n', 'q', '<Nop>', opts)

-- Command mode up/down remap
keymap('c', '<C-k>', function()
  return '<Up>'
end, { expr = true })
keymap('c', '<C-j>', function()
  return '<Down>'
end, { expr = true })

-- Next/Previous result
keymap('n', '<c-n>', ':cn<cr>', opts)
keymap('n', '<c-p>', ':cp<cr>', opts)

-- Tab navigation
keymap('n', '<c-j>', ':tabnext<cr>', opts)
keymap('n', '<c-k>', ':tabprev<cr>', opts)
keymap('i', '<c-j>', '<c-o>:tabnext<cr>', opts)
keymap('i', '<c-k>', '<c-o>:tabprev<cr>', opts)
keymap('n', '<c-l>', ':tabm +1<cr>', opts)
keymap('n', '<c-h>', ':tabm -1<cr>', opts)
keymap('n', 'gd', ':tabclose<cr>', opts)
keymap('n', 'ga', ':tabnew<cr>', opts)
keymap('n', 'gs', ':tab split<cr>', opts)
keymap('n', 'go', ':tabonly<cr>', opts)

-- Terminal escape

keymap('t', '<esc>', '<c-\\><c-n>', opts)

local function search_with_two_chars(search_command)
  return function()
    local char1 = vim.fn.getchar()
    local char2 = vim.fn.getchar()

    char1 = vim.fn.nr2char(char1)
    char2 = vim.fn.nr2char(char2)

    local search_term = char1 .. char2

    vim.api.nvim_feedkeys(search_command .. search_term .. '\n', 'n', false)

    vim.schedule(function()
      vim.cmd('nohlsearch')
    end)
  end
end

keymap('n', 's', search_with_two_chars('/'), opts)
keymap('x', 's', search_with_two_chars('/'), opts)
keymap('n', 'S', search_with_two_chars('?'), opts)
keymap('x', 'S', search_with_two_chars('?'), opts)

local function get_current_dir_files()
  -- Get the directory of the current file
  local current_file = vim.fn.expand('%:p')
  local current_dir = vim.fn.expand('%:p:h')

  -- Get all files in the directory
  local files = vim.fn.glob(current_dir .. '/*', false, true)

  -- Filter out directories and hidden files
  local regular_files = {}
  for _, file in ipairs(files) do
    if vim.fn.isdirectory(file) == 0 and string.sub(vim.fn.fnamemodify(file, ':t'), 1, 1) ~= '.' then
      table.insert(regular_files, file)
    end
  end

  -- Sort files to ensure consistent ordering
  table.sort(regular_files)

  return regular_files, current_file
end

local function navigate_files(direction)
  return function()
    local files, current_file = get_current_dir_files()
    if #files == 0 then
      return
    end

    -- Find current file index
    local current_index = 1
    for i, file in ipairs(files) do
      if file == current_file then
        current_index = i
        break
      end
    end

    -- Calculate next/previous index with wrapping
    local new_index
    if direction == 'next' then
      new_index = current_index % #files + 1
    else -- previous
      new_index = (current_index - 2 + #files) % #files + 1
    end

    -- Edit the new file
    vim.cmd('edit ' .. vim.fn.fnameescape(files[new_index]))
  end
end

-- Add these to your existing keymaps
keymap('n', '<right>', navigate_files('next'), opts)
keymap('n', '<left>', navigate_files('previous'), opts)
