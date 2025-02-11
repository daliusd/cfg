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
        { "<leader>s", group = "search" },
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
        '<leader>sg',
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
        '<leader>bb',
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
      { '<leader>m',  vim.lsp.buf.code_action, silent = true, desc = 'code actions' },
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
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup({
        winopts = { height = 1, width = 1, preview = { border = 'noborder', layout = 'vertical' } },
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
        '<leader>ss',
        function()
          local text = vim.fn.expand("<cword>")
          vim.fn.histadd(':', 'Rg ' .. text)
          require("fzf-lua").live_grep_glob({ search = text })
        end,
        silent = true,
        desc = 'Rg'
      },
      {
        '<leader>ss',
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
        '<leader>sg',
        function()
          local text = vim.getVisualSelection()
          vim.fn.histadd(':', 'gr ' .. text)
          vim.cmd('silent gr ' .. text)
        end,
        mode = 'v',
        silent = true,
        desc = 'gr',
      },
      { '<leader>sr', ':FzfLua live_grep_glob<cr>', silent = true },
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

      { '<leader>c',  ':FzfLua commands<cr>',       silent = true, desc = 'Commands' },
      { '<leader>z',  ':FzfLua spell_suggest<cr>',  silent = true, desc = 'Spell suggest' },
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
  {
    "kylechui/nvim-surround",
    config = true,
  },
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

          if client ~= nil and client.supports_method('textDocument/formatting') then
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
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          buffer = {
            min_keyword_length = 1,
          }
        },
        cmdline = {},
      },

      keymap = {
        preset = 'none',
        ['<C-i>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'mono',
      },
      signature = { enabled = true },

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
  { "sindrets/diffview.nvim" },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gg',  ':Git<cr>',        silent = true, desc = 'Git' },
      { '<leader>gd',  ':Gdiffsplit<cr>', silent = true, desc = 'Git diff split' },
      { '<leader>gb',  ':Git blame<cr>',  silent = true, desc = 'Git blame' },
      { '<leader>gps', ':Git push<cr>',   silent = true, desc = 'Git push' },
      { '<leader>gpl', ':Git pull<cr>',   silent = true, desc = 'Git pull' },
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
    build = ':TSUpdate',
    config = function()
      require 'nvim-treesitter.configs'.setup {
        ensure_installed = {
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
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(_, bufnr)
            -- Treesitter is slow on large files. Disable if files is larger than 256kb
            local buf_name = vim.api.nvim_buf_get_name(bufnr)
            local file_size = vim.api.nvim_call_function("getfsize", { buf_name })
            return file_size > 256 * 1024
          end,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
          },
        },
        indent = {
          enable = false,
          disable = {},
        },
        modules = {},
      }
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
    "allaman/emoji.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function(_, opts)
      require("emoji").setup(opts)
    end,
  },
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
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "copilot",
            keymaps = {
              change_adapter = { modes = { n = "ca" } },
              debug = { modes = { n = "cd" } },
              system_prompt = { modes = { n = "cs" } },
            }
          },
          inline = {
            adapter = "copilot",
            keymaps = {
              accept_change = { modes = { n = "ca", }, },
              reject_change = { modes = { n = "cr", }, },
            },
          },
        },
        adapters = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  -- default = "gpt-4o",
                  -- default = "o3-mini",
                  default = "claude-3.5-sonnet",
                  -- default = "gemini-2.0-flash-001",
                },
              },
            })
          end,
          githubmodels = function()
            return require("codecompanion.adapters").extend("githubmodels", {
              schema = {
                model = {
                  default = "Codestral-2501",
                },
              },
            })
          end,
        },
      })

      vim.api.nvim_set_keymap("n", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", "<leader>ba", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
})

require('misc')
require('highlights')
require('todo')
require('keymaps')
require('commands')
