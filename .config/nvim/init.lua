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

require("lazy").setup({
  {
    "rose-pine/neovim",
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.g['zenbones_compat'] = 1
      -- vim.cmd([[colorscheme zenbones]])
      vim.cmd([[colorscheme rose-pine]])
    end,
  },

  -- Generic plugins

  'nvim-tree/nvim-web-devicons',
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
      { '<leader>h', ':FzfLua oldfiles<cr>', silent = true },
      { '<leader>f', ':FzfLua files<cr>',    silent = true },
      {
        '<leader>r',
        function()
          local text = vim.fn.expand("<cword>")
          vim.fn.histadd(':', 'Rg ' .. text)
          require("fzf-lua").live_grep_glob({ search = text })
        end,
        silent = true
      },
      {
        '<leader>r',
        function()
          local text = vim.getVisualSelection()
          vim.fn.histadd(':', 'Rg ' .. text)
          require("fzf-lua").live_grep_glob({ search = text })
        end,
        mode = 'v',
        silent = true
      },
      {
        '<leader>g',
        function()
          local text = vim.getVisualSelection()
          vim.fn.histadd(':', 'gr ' .. text)
          vim.cmd('silent gr ' .. text)
        end,
        mode = 'v',
        silent = true
      },
      { '<leader>R', ':FzfLua live_grep_glob<cr>', silent = true },
      {
        '<leader>f',
        function()
          local text = vim.getVisualSelection()
          require("fzf-lua").files({ query = text })
        end,
        mode = 'v',
        silent = true
      },

      { '<leader>c', ':FzfLua commands<cr>',       silent = true },
      { '<leader>z', ':FzfLua spell_suggest<cr>',  silent = true },
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
      -- win_options = {
      --   signcolumn = "yes:2",
      -- },
    },
    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Open Parent directory",
        silent = true
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- {
  --   "refractalize/oil-git-status.nvim",
  --   dependencies = {
  --     "stevearc/oil.nvim",
  --   },
  --   config = true,
  -- },
  {
    "ggandor/leap.nvim",
    config = function()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward-to)');
      vim.keymap.set({ 'n' }, 'S', '<Plug>(leap-backward-to)');
      require('leap').add_repeat_mappings('<tab>', '<s-tab>', {
        relative_directions = true,
        modes = { 'n', 'x', 'o' },
      })
    end
  },
  {
    "kylechui/nvim-surround",
    config = true,
  },
  'tpope/vim-abolish',
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
      -- NOTE: I am not sure if I need this one.
      -- require 'lspconfig'.quick_lint_js.setup {}
      require 'lspconfig'.sqlls.setup {}
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
      require 'lspconfig'.vimls.setup {}

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
    lazy = false,
    version = 'v0.*',
    -- dependencies = {
    --   { 'rafamadriz/friendly-snippets' },
    -- },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        completion = {
          enabled_providers = { 'lsp', 'path', 'snippets', 'buffer' }
        },
      },

      keymap = {
        preset = 'enter',
        ['<C-i>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
      },

      highlight = {
        use_nvim_cmp_as_default = true,
      },
      nerd_font_variant = 'mono',
      accept = { auto_brackets = { enabled = true } },
      trigger = { signature_help = { enabled = true } },

      windows = {
        autocomplete = {
          selection = 'auto_insert',
        },
        documentation = {
          auto_show = true,
        }
      },

    },
    opts_extend = { "sources.completion.enabled_providers" }
  },
  'jamessan/vim-gnupg',
  {
    'sQVe/sort.nvim',
    config = true,
  },
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
    'tpope/vim-fugitive',
    config = function()
      -- editorconfig-vim
      vim.g['EditorConfig_exclude_patterns'] = { 'fugitive://.*' }

      -- Fugitive
      vim.cmd(":cnoreabbrev <expr> gps (getcmdtype() == ':' && getcmdline() ==# 'gps') ? 'Git push' : 'gps'")
      vim.cmd(":cnoreabbrev <expr> gpl (getcmdtype() == ':' && getcmdline() ==# 'gpl') ? 'Git pull' : 'gpl'")
      vim.cmd(":cnoreabbrev <expr> gs (getcmdtype() == ':' && getcmdline() ==# 'gs') ? 'Git' : 'gs'")
      vim.cmd(":cnoreabbrev <expr> gd (getcmdtype() == ':' && getcmdline() ==# 'gd') ? 'Gdiffsplit' : 'gd'")
      vim.cmd(":cnoreabbrev <expr> gb (getcmdtype() == ':' && getcmdline() ==# 'gb') ? 'Git blame' : 'gb'")
    end
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
    end
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
  -- {
  --   'rmagatti/gx-extended.nvim',
  --   config = function()
  --     require('gx-extended').setup({
  --       open_fn = require 'lazy.util'.open,
  --     })
  --   end
  -- },
  -- 'jbyuki/venn.nvim',
  -- 'sindrets/diffview.nvim',
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
      { '<leader>us', ':GHLitePRSelect<cr>',        silent = true },
      { '<leader>uo', ':GHLitePRCheckout<cr>',      silent = true },
      { '<leader>uv', ':GHLitePRView<cr>',          silent = true },
      { '<leader>uu', ':GHLitePRLoadComments<cr>',  silent = true },
      { '<leader>up', ':GHLitePRDiff<cr>',          silent = true },
      { '<leader>ul', ':GHLitePRDiffview<cr>',      silent = true },
      { '<leader>ua', ':GHLitePRAddComment<cr>',    silent = true },
      { '<leader>ua', ':GHLitePRAddComment<cr>',    mode = 'v',   silent = true },
      { '<leader>uc', ':GHLitePRUpdateComment<cr>', silent = true },
      { '<leader>ud', ':GHLitePRDeleteComment<cr>', silent = true },
      { '<leader>ug', ':GHLitePROpenComment<cr>',   silent = true },
    }
  },
  -- {
  --   "robitx/gp.nvim",
  --   config = function()
  --     local conf = {
  --       providers = {
  --         openai = {},
  --         googleai = {
  --           endpoint =
  --           "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
  --           secret = { 'pass', 'show', 'googleai' }
  --         },
  --       },
  --       agents = {
  --         {
  --           name = "ChatGPT3-5",
  --           disable = true,
  --         },
  --       }
  --     }
  --     require("gp").setup(conf)
  --   end,
  -- }
})

require('misc')
require('highlights')
require('todo')
require('keymaps')
require('commands')
