local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

vim.g.mapleader = ' ' -- we need to setup this before plugins

function vim.getVisualSelection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end

require('opts')

local function on_list(options)
  vim.fn.setqflist({}, ' ', options)
  vim.api.nvim_command('cfirst')
end

require("lazy").setup({
  {
    "rose-pine/neovim",
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme rose-pine]])
    end,
    keys = {
      { '<leader>l', ':Lazy<cr>', silent = true, desc = 'Lazy' },
    }
  },

  -- Generic plugins
  'nvim-tree/nvim-web-devicons',
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        delay = function(ctx)
          return ctx.plugin and 0 or 500
        end,
      })
      wk.add({
        { "<leader>a", group = "lsp" },
        { "<leader>w", group = "window" },
        { "<leader>g", group = "git" },
        { "<leader>u", group = "ghlite" },
      })
    end,
    keys = {
      {
        '<leader>e',
        vim.diagnostic.open_float,
        silent = true,
        desc = 'Diagnostics float'
      },
      {
        '<leader>ak',
        function() vim.diagnostic.jump({ count = -1, float = true }) end,
        silent = true,
        desc = 'Diagnostics prev'
      },
      {
        '<leader>ap',
        function()
          vim.diagnostic.jump({
            count = -1,
            float = true,
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        silent = true,
        desc = 'Diagnostics Error prev'
      },
      {
        '<leader>aj',
        function() vim.diagnostic.jump({ count = 1, float = true }) end,
        silent = true,
        desc = 'Diagnostics next'
      },
      {
        '<leader>an',
        function()
          vim.diagnostic.jump({
            count = 1,
            float = true,
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        silent = true,
        desc = 'Diagnostics Error next'
      },
      -- Grep
      {
        '<leader>G',
        function()
          local text = vim.fn.expand("<cword>")
          vim.fn.histadd(':', 'gr ' .. text)
          vim.cmd('silent gr ' .. text)
        end,
        silent = true,
        desc = 'Grep word'
      },
      -- Misc
      { '<leader>n', ':silent noh<cr>',             silent = true, desc = 'noh' },
      { '<leader>q', ':qa<cr>',                     silent = true, desc = 'quit' },
      { '<leader>p', ":let @+ = expand('%:p')<cr>", silent = true, desc = 'copy full path' },
      { '<leader>o', ":let @+ = expand('%:t')<cr>", silent = true, desc = 'copy file name' },
      { '<leader>s', ':w<cr>',                      silent = true, desc = 'write' },

      {
        '<leader>b',
        ':CodeCompanionChat Toggle<cr>',
        mode = { 'n', 'v' },
        silent = true,
        desc = 'CodeCompanionChat'
      },

      -- window commands
      { '<leader>ww', '<c-w>w', silent = true, desc = 'window switch' },
      { '<leader>wc', '<c-w>c', silent = true, desc = 'window close' },
      { '<leader>wo', '<c-w>o', silent = true, desc = 'window close other' },
      { '<leader>wh', '<c-w>h', silent = true, desc = 'window k' },
      { '<leader>wj', '<c-w>j', silent = true, desc = 'window j' },
      { '<leader>wk', '<c-w>k', silent = true, desc = 'window k' },
      { '<leader>wl', '<c-w>l', silent = true, desc = 'window l' },
      -- LSP
      -- Mapping to c-] because LSP go to definition then works with c-t
      { '<leader>d',  '<c-]>',  silent = true, desc = 'definition' },
      {
        '<leader>aa',
        function()
          local bufnr = vim.api.nvim_get_current_buf();

          local content = require("codecompanion.utils.buffers").format_with_line_numbers(bufnr)

          local name = require("codecompanion").last_chat().references:make_id_from_buf(bufnr)
          if name == "" then
            name = "Buffer " .. bufnr
          end
          local id = "<buf>" .. name .. "</buf>"

          local path = vim.api.nvim_buf_get_name(bufnr)
          local message = "Here is the content from"

          require("codecompanion").last_chat():add_message({
            role = 'user',
            content = string.format(
              [[%s `%s` (which has a buffer number of _%d_ and a filepath of `%s`):

%s]],
              message,
              vim.fn.fnamemodify(path, ":t"),
              bufnr,
              path,
              content
            ),
          }, { reference = id, visible = false })

          require("codecompanion").last_chat().references:add({
            bufnr = bufnr,
            id = id,
            path = path,
            source = "codecompanion.strategies.chat.slash_commands.buffer",
            opts = {}
          })
          vim.print('buffer added to chat')
        end,
        silent = true,
        desc = 'buffer to CodeCompanion chat'
      },
      {
        '<leader>ad',
        function() vim.lsp.buf.declaration { on_list = on_list } end,
        silent = true,
        desc = 'declaration'
      },
      { '<leader>k',  vim.lsp.buf.hover,       silent = true, desc = 'hover' },
      {
        '<leader>at',
        function() vim.lsp.buf.type_definition { on_list = on_list } end,
        silent = true,
        desc = 'type definition'
      },
      { '<leader>ar', vim.lsp.buf.rename,      silent = true, desc = 'rename' },
      { '<leader>m',  vim.lsp.buf.code_action, silent = true, desc = 'code actions' },
      {
        '<leader>m',
        vim.lsp.buf.code_action,
        mode = 'v',
        silent = true,
        desc = 'code actions'
      },
      {
        '<leader>/',
        function() vim.lsp.buf.references(nil, { on_list = on_list }) end,
        silent = true,
        desc = 'references'
      },

      -- vimrc file
      { '<leader>v', ':e ~/.config/nvim/init.lua<cr>', silent = true, desc = 'load nvim init.lua' },
      { '<leader>V', ':source $MYVIMRC<cr>',           silent = true, desc = 'source nvim init.lua' },
      {
        '<leader>gc',
        function()
          require "gitlinker".get_repo_url({
            action_callback = function(url)
              local commit = vim.fn.expand("<cword>")
              require "gitlinker.actions".open_in_browser(url .. '/commit/' .. commit)
            end
          })
        end,
        silent = true,
        desc = 'Open commit in browser',
      },
    }
  },
  {
    'j-hui/fidget.nvim',
    opts = {
      -- options
      notification = {
        override_vim_notify = true,
      }
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          theme = 'auto'
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            {
              'filename',
              path = 3,
            },
          },
          lualine_x = { 'encoding', 'fileformat', 'filetype',
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              sections = { 'error', 'warn', 'info', 'hint' },
              symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' }
            }
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        tabline = {
          lualine_a = {
            {
              'tabs',
              max_length = vim.o.columns,
              mode = 2,
              tabs_color = { active = 'lualine_a_normal', inactive = 'lualine_c_normal' },
            },
          },
          lualine_z = { 'filesize' }
        },
      }
    end
  },
  {
    "ibhagwan/fzf-lua",
    config = function()
      local fzf_lua = require("fzf-lua");
      fzf_lua.setup({
        winopts = { height = 0.95, width = 0.95, preview = { border = 'rounded', layout = 'vertical' } },
        files = {
          git_icons = false,
        },
        grep = {
          git_icons = false,
          actions = {
            ["ctrl-l"] = { function()
              local text = require("fzf-lua").get_last_query() .. " -- *_en.json"
              require("fzf-lua").live_grep_glob({ search = text, no_esc = true })
            end },
            ["ctrl-g"] = { function()
              local text = require("fzf-lua").get_last_query() .. " -- *.js *.jsx *.ts *.tsx"
              require("fzf-lua").live_grep_glob({ search = text, no_esc = true })
            end },
          },
        }
      })
      vim.cmd('FzfLua register_ui_select')
    end,
    lazy = false,
    keys = {
      { '<leader>h', ':FzfLua oldfiles<cr>', silent = true, desc = 'Old files' },
      { '<leader>f', ':FzfLua files<cr>',    silent = true, desc = 'Files' },
      {
        '<leader>r',
        function()
          local text = vim.fn.expand("<cword>")
          vim.fn.histadd(':', 'Rg ' .. text)
          require("fzf-lua").live_grep_glob({ search = text })
        end,
        silent = true,
        desc = 'Rg'
      },
      {
        '<leader>r',
        function()
          local text = vim.getVisualSelection()
          vim.fn.histadd(':', 'Rg ' .. text)
          require("fzf-lua").live_grep_glob({ search = text })
        end,
        mode = 'v',
        silent = true,
        desc = 'Rg'
      },
      {
        '<leader>G',
        function()
          local text = vim.getVisualSelection()
          vim.fn.histadd(':', 'gr ' .. text)
          vim.cmd('silent gr ' .. text)
        end,
        mode = 'v',
        silent = true,
        desc = 'gr',
      },
      { '<leader>R', ':FzfLua live_grep_glob<cr>', silent = true },
      {
        '<leader>f',
        function()
          local text = vim.getVisualSelection()
          require("fzf-lua").files({ query = text })
        end,
        mode = 'v',
        silent = true,
        desc = 'Files',
      },

      { '<leader>c', ':FzfLua commands<cr>',       silent = true, desc = 'Commands' },
      {
        '<leader>c',
        ':FzfLua commands<cr>',
        silent = true,
        mode = 'v',
        desc = 'Commands'
      },
      { '<leader>z', ':FzfLua spell_suggest<cr>', silent = true, desc = 'Spell suggest' },
    }
  },
  {
    'stevearc/oil.nvim',
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
        "size",
      },
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['gs'] = false,
      }
    },
    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Open Parent directory",
        silent = true,
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- {
  --   "kylechui/nvim-surround",
  --   config = true,
  -- },
  {
    'numToStr/Comment.nvim',
    config = true,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      require('lspconfig').yamlls.setup {
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*"
            },
          },
        }
      }

      require 'lspconfig'.ansiblels.setup {}
      require 'lspconfig'.astro.setup {}
      require 'lspconfig'.buf_ls.setup {}
      require 'lspconfig'.cssls.setup {
        capabilities = capabilities
      }
      require 'lspconfig'.cssmodules_ls.setup {}

      require 'lspconfig'.eslint.setup({
        settings = {
          packageManager = 'yarn'
        },
        ---@diagnostic disable-next-line: unused-local
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })

      require 'lspconfig'.html.setup {
        capabilities = capabilities,
        on_attach =
            function(client)
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end
      }
      require 'lspconfig'.jsonls.setup {
        capabilities = capabilities,
      }
      require 'lspconfig'.pyright.setup {}
      require 'lspconfig'.sqlls.setup {}
      require 'lspconfig'.typos_lsp.setup {}
      -- require 'lspconfig'.ts_ls.setup {}
      require 'lspconfig'.lua_ls.setup {
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
            hint = { enable = true },
          },
        },
      }

      -- Format on write
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if client ~= nil and client.supports_method('textDocument/formatting') and client.name ~= 'ts_ls' then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end,
            })
          end
        end,
      })
    end
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require('lint').linters_by_ft = {
        javascript = { 'langd' },
        javascriptreact = { 'langd' },
        typescript = { 'langd' },
        typescriptreact = { 'langd' },
      }

      vim.api.nvim_create_autocmd({ "BufRead", "InsertLeave", "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })

      require('lint').linters.langd = {
        name = 'langd',
        cmd = 'langd',
        stdin = true,
        args = { vim.fn.getcwd() },
        stream = 'stdout',
        parser = require('lint.parser').from_pattern(
          '(%d+):(%d+):(%d+) (.*)',
          { "lnum", "col", "end_col", "message" },
          nil,
          {
            ["source"] = "langd",
            ["severity"] = vim.diagnostic.severity.INFO,
          })
      }
    end
  },
  {
    'stevearc/conform.nvim',
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          html = { "prettierd" },
          javascript = { "prettierd" },
          javascriptreact = { "prettierd" },
          markdown = { "prettierd" },
          typescript = { "prettierd" },
          typescriptreact = { "prettierd" },
          ["*"] = { "trim_whitespace" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters = {
          prettierd = {
            condition = function()
              return vim.loop.fs_realpath(".prettierrc.js") ~= nil or vim.loop.fs_realpath(".prettierrc.mjs") ~= nil or
                  vim.loop.fs_realpath(".prettierrc.json")
            end,
          },
        },
      })
    end,
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
    config = function()
      require("typescript-tools").setup {
        on_attach =
            function(client, _)
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end,
        settings = {
          tsserver_path = vim.env.HOME ..
              "/.volta/tools/image/packages/typescript/lib/node_modules/typescript/lib/tsserver.js",
          jsx_close_tag = {
            enable = true,
            filetypes = { "javascriptreact", "typescriptreact" },
          }
        }
      }
    end
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },
  {
    'saghen/blink.cmp',
    version = '*',
    dependencies = {
      "moyiz/blink-emoji.nvim",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'emoji' },
        providers = {
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 15,
            opts = { insert = true },
          }
        }
      },

      keymap = {
        preset = 'none',
        ['<C-i>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<Tab>'] = { 'fallback' },
        ['<S-Tab>'] = { 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'mono',
      },
      signature = { enabled = true },

      cmdline = {
        enabled = false,
      },

      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        documentation = {
          auto_show = true,
        },
      },

    },
    opts_extend = { "sources.completion.enabled_providers" }
  },
  'jamessan/vim-gnupg',
  -- Git
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true })
        end
      }
    end,
  },
  {
    "sindrets/diffview.nvim",
    opts = {
      keymaps = {
        view = {
          ["<leader>e"] = false,
        }
      }
    }

  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gg', ':Git<cr>',         silent = true, desc = 'Git' },
      { '<leader>gd', ':Gvdiffsplit<cr>', silent = true, desc = 'Git diff split' },
      { '<leader>gb', ':Git blame<cr>',   silent = true, desc = 'Git blame' },
      { '<leader>gp', ':Git push<cr>',    silent = true, desc = 'Git push' },
      { '<leader>gl', ':Git pull<cr>',    silent = true, desc = 'Git pull' },
    }
  },
  {
    'ruifm/gitlinker.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require "gitlinker".setup({
        mappings = "<leader>x"
      })
    end,
  },
  -- Tree-sitter
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      require 'nvim-treesitter'.setup {
        install_dir = vim.fn.stdpath('data') .. '/site',
      }

      local ensureInstalled = {
        'c',
        'cmake',
        'comment',
        'cpp',
        'css',
        'diff',
        'dockerfile',
        'fish',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gpg',
        'html',
        'htmldjango',
        'http',
        'javascript',
        'jq',
        'json',
        'lua',
        'luadoc',
        'make',
        'markdown',
        'markdown_inline',
        'mermaid',
        'python',
        'regex',
        'rust',
        'sql',
        'svelte',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      }

      require("nvim-treesitter").install(ensureInstalled)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'c',
          'cmake',
          'cpp',
          'css',
          'diff',
          'dockerfile',
          'fish',
          'gitconfig',
          'gitrebase',
          'gitattributes',
          'gitcommit',
          'gitignore',
          'go',
          'gpg',
          'html',
          'htmldjango',
          'http',
          'javascript',
          'json',
          'lua',
          'make',
          'markdown',
          'mermaid',
          'python',
          'rust',
          'sql',
          'svelte',
          'typescript',
          'typescriptreact', -- for tsx
          'vim',
          'help',            -- for vimdoc
          'xml',
          'yaml',
        },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end
  },
  {
    dir = "~/projects/ghlite.nvim",
    config = function()
      require('ghlite').setup({
        debug = false,
        view_split = '',
        diff_split = '',
        open_command = 'open',
        keymaps = {
          diff = {
            open_file_tab = 'gt',
          },
        },
      })
    end,
    keys = {
      { '<leader>us', ':GHLitePRSelect<cr>',        silent = true, desc = 'PR Select' },
      { '<leader>uo', ':GHLitePRCheckout<cr>',      silent = true, desc = 'PR Checkout' },
      { '<leader>uv', ':GHLitePRView<cr>',          silent = true, desc = 'PR View' },
      { '<leader>uu', ':GHLitePRLoadComments<cr>',  silent = true, desc = 'PR Load Comments' },
      { '<leader>up', ':GHLitePRDiff<cr>',          silent = true, desc = 'PR Diff' },
      { '<leader>ul', ':GHLitePRDiffview<cr>',      silent = true, desc = 'PR Diffview' },
      { '<leader>ua', ':GHLitePRAddComment<cr>',    silent = true, desc = 'PR Add comment' },
      { '<leader>ua', ':GHLitePRAddComment<cr>',    mode = 'x',    silent = true,             desc = 'PR Add comment' },
      { '<leader>uc', ':GHLitePRUpdateComment<cr>', silent = true, desc = 'PR Update comment' },
      { '<leader>ud', ':GHLitePRDeleteComment<cr>', silent = true, desc = 'PR Delete comment' },
      { '<leader>ug', ':GHLitePROpenComment<cr>',   silent = true, desc = 'PR Open comment' },
    }
  },
  "tpope/vim-abolish",
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = false,
        },
      })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    -- dir = "~/projects/rare/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "j-hui/fidget.nvim",
      "ravitemer/mcphub.nvim",
    },
    config = function()
      local function create_adapter(adapter_name, default_model)
        return require("codecompanion.adapters").extend(adapter_name, {
          schema = {
            model = {
              default = default_model,
            },
          },
        })
      end

      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "copilot_claude_sonnet",
            keymaps = {
              change_adapter = { modes = { n = "ca" } },
              debug = { modes = { n = "cd" } },
              system_prompt = { modes = { n = "cs" } },
            },
          },
          inline = {
            adapter = "copilot_claude_sonnet",
            keymaps = {
              accept_change = { modes = { n = "ca" } },
              reject_change = { modes = { n = "cr" } },
            },
          },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              show_result_in_chat = true, -- Show mcp tool results in chat
              make_vars = true,           -- Convert resources to #variables
              make_slash_commands = true, -- Add prompts as /slash commands
            }
          }
        },
        adapters = {
          copilot_claude_sonnet = function()
            return create_adapter("copilot", "claude-3.5-sonnet")
          end,
          copilot_gemini_2_5_pro = function()
            return create_adapter("copilot", "gemini-2.5-pro")
          end,
          copilot_gpt_41 = function()
            return create_adapter("copilot", "gpt-4.1")
          end,
        },
      })
      require("fidget-spinner"):init()

      vim.api.nvim_set_keymap("n", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })

      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
  {
    'Vigemus/iron.nvim',
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")

      iron.setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            typescript = {
              command = { "tsx" }
            },
            typescriptreact = {
              command = { "tsx" }
            },
          },
          repl_open_cmd = view.split.vertical.rightbelow("%40"),
        },

        keymaps = {
          toggle_repl = "<leader>ir",
          restart_repl = "<leader>iR",
          send_motion = "<leader>ic",
          visual_send = "<leader>ic",
          send_file = "<leader>if",
          send_line = "<leader>il",
          cr = "<leader>i<cr>",
          interrupt = "<leader>i<space>",
          exit = "<leader>iq",
          clear = "<leader>ix",
        },
        highlight = {
          italic = true
        },
        ignore_blank_lines = true,
      }
    end
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = "MCPHub",
    build = "npm install -g mcp-hub@latest",
    config = function()
      local hostname = vim.fn.hostname()
      local config = vim.fn.expand("~/.config/mcphub/servers2.json")
      if hostname == "avokadas" then
        config = vim.fn.expand("~/.config/mcphub/servers.json")
      end

      require("mcphub").setup({
        port = 4000,
        config = config,
      })
    end
  }
})



require('misc')
require('highlights')
require('todo')
require('keymaps')
require('commands')
