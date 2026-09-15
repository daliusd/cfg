local prompts = {
  {
    name = 'Review first comment',
    text = 'Review first unresolved gh comment',
  },
  {
    name = 'Create branch and commit',
    text = 'Create branch and conventional commit',
  },
  {
    name = 'Respond and resolve',
    text = 'Respond and resolve gh comment',
  },
}

local function insert_prompt()
  vim.ui.select(prompts, {
    prompt = 'Insert prompt',
    format_item = function(prompt)
      return prompt.name
    end,
  }, function(prompt)
    if not prompt then
      return
    end

    vim.api.nvim_put(vim.split(prompt.text, '\n', { plain = true }), 'c', true, true)
  end)
end

vim.api.nvim_create_user_command('InsertPrompt', insert_prompt, {})
vim.keymap.set('n', '<leader>P', insert_prompt, { silent = true, desc = 'Insert prompt' })
