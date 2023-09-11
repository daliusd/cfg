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

require("lazy").setup({
  {
    "mcchrish/zenbones.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g['zenbones_compat'] = 1
      vim.cmd([[colorscheme zenbones]])
    end,
  },

  -- Generic plugins

  'nvim-tree/nvim-web-devicons',
  {
    'nvim-lua/lsp-status.nvim',
    config = function()
      local lsp_status = require('lsp-status')
      lsp_status.register_progress()
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          theme = 'zenbones'
        },
        extensions = { 'neo-tree' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            {
              'filename',
              path = 3,
            },
            "require'lsp-status'.status()"
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
              fmt = function(name, context)
                local buflist = vim.fn.tabpagebuflist(context.tabnr)
                local winnr = vim.fn.tabpagewinnr(context.tabnr)
                local bufnr = buflist[winnr]
                local mod = vim.fn.getbufvar(bufnr, '&mod')

                return name .. (mod == 1 and ' +' or '')
              end
            },
          },
          lualine_z = { 'filesize' }
        },
      }
    end
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-live-grep-args.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'piersolenski/telescope-import.nvim',
    },
    config = function()
      local actions = require("telescope.actions")
      local lga_actions = require("telescope-live-grep-args.actions")

      require("telescope").setup({
        defaults = {
          layout_strategy = 'vertical',
          layout_config = { height = 0.95, preview_cutoff = 20 },
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<c-c>"] = false,
              ["<c-j>"] = actions.move_selection_next,
              ["<c-k>"] = actions.move_selection_previous,
              ["<C-u>"] = actions.results_scrolling_up,
              ["<C-d>"] = actions.results_scrolling_down,
            },
          },
        },
        extensions = {
          live_grep_args = {
            mappings = {
              i = {
                ["<C-f>"] = lga_actions.quote_prompt({ postfix = " -g *{js,jsx,ts,tsx}" }),
                ["<C-l>"] = lga_actions.quote_prompt({ postfix = " -g *en*" }),
              },
            },
          },
          import = {
            insert_at_top = false,
          },
        },
      })

      local telescope = require('telescope')
      telescope.load_extension('fzf')
      telescope.load_extension('live_grep_args')
      telescope.load_extension('ui-select')
      telescope.load_extension('import')
    end,
    cmd = { 'Telescope' },
    keys = {
      { '<leader>h', ':Telescope oldfiles<cr>',   silent = true },
      { '<leader>f', ':Telescope find_files<cr>', silent = true },
      {
        '<leader>r',
        function()
          local text = vim.fn.expand("<cword>")
          vim.fn.histadd(':', 'Rg ' .. text)
          require('telescope').extensions.live_grep_args.live_grep_args({ default_text = text })
        end,
        silent = true
      },
      {
        '<leader>r',
        function()
          local text = vim.getVisualSelection()
          vim.fn.histadd(':', 'Rg ' .. text)
          require('telescope').extensions.live_grep_args.live_grep_args({ default_text = text })
        end,
        mode = 'v',
        silent = true
      },
      { '<leader>R', ':Telescope live_grep_args<cr>', silent = true },
      { '<leader>c', ':Telescope commands<cr>',       silent = true },
      { '<leader>z', ':Telescope spell_suggest<cr>',  silent = true },
    }
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>b", ":Neotree left filesystem reveal toggle<cr>",            desc = "NeoTree",     silent = true },
      { "-",         ":Neotree float filesystem reveal reveal_force_cwd<cr>", desc = "NeoTree CWD", silent = true },
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = { -- show hidden files
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = true,
          },

          find_by_full_path_words = true, -- make filter work properly

          window = {
            fuzzy_finder_mappings = {
              ["<down>"] = "move_cursor_down",
              ["<C-j>"] = "move_cursor_down",
              ["<up>"] = "move_cursor_up",
              ["<C-k>"] = "move_cursor_up",
            },
          }
        }
      })
    end,
  },
  {
    "ggandor/leap.nvim",
    config = function()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward-to)');
      vim.keymap.set({ 'n', 'x', 'o' }, 'cc', '<Plug>(leap-backward-to)');
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
    'vim-test/vim-test',
    keys = {
      { '<leader>t', ':TestNearest<cr>', silent = true },
      { '<leader>T', ':TestFile<cr>',    silent = true },
    }
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp',
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

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
      require 'lspconfig'.bashls.setup {}
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
          },
        },
      }
      require 'lspconfig'.vimls.setup {}

      -- Format on write
      vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        callback = function()
          if #vim.lsp.buf_get_clients() > 0 then
            vim.lsp.buf.format()
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

      vim.api.nvim_create_autocmd({ "BufRead", "InsertLeave" }, {
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
    'mhartington/formatter.nvim',
    config = function()
      local prettierd = function()
        if not vim.loop.fs_realpath(".prettierrc.js") then
          return nil
        end

        return {
          exe = "prettierd",
          args = { vim.api.nvim_buf_get_name(0) },
          stdin = true
        }
      end

      require("formatter").setup {
        logging = true,
        log_level = vim.log.levels.WARN,

        filetype = {
          javascript = { prettierd },
          javascriptreact = { prettierd },
          typescript = { prettierd },
          typescriptreact = { prettierd },
          html = { prettierd },
          markdown = { prettierd },
          ["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace }
        }
      }

      vim.api.nvim_create_autocmd("BufWritePost", {
        command = "FormatWrite",
      })
    end
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
    config = function()
      require("typescript-tools").setup {
        on_attach =
            function(client)
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end
      }
    end
  },
  {
    'petertriho/cmp-git',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = true,
  },
  'sindrets/diffview.nvim',
  'windwp/nvim-autopairs',
  {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
    },
    config = function()
      local cmp = require 'cmp'

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp', priority = 20 },
          {
            name = 'buffer',
            priority = 9,
            option = {
              indexing_interval = 1000,
              max_indexed_line_length = 512,
              get_bufnrs = function()
                local bufs = vim.api.nvim_list_bufs()

                local result = {}
                for _, v in ipairs(bufs) do
                  local byte_size = vim.api.nvim_buf_get_offset(v, vim.api.nvim_buf_line_count(v))
                  if byte_size < 1024 * 1024 then result[#result + 1] = v end
                end

                return result
              end
            }
          },
          { name = 'path',     priority = 8 },
          { name = 'emoji',    priority = 7 },
          { name = 'git',      priority = 6 },
        }),
      })

      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      require('nvim-autopairs').setup {}
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
    end,
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

      vim.g.fugitive_legacy_commands = 1
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
  {
    'anuvyklack/pretty-fold.nvim',
    config = true,
  },
}, {
  checker = {
    -- automatically check for plugin updates
    enabled = true,
    notify = true,
    frequency = 7200,
  },
})

require('opts')
require('misc')
require('highlights')
require('todo')
require('keymaps')
require('commands')
