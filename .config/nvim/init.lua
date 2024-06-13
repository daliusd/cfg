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
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        winopts = { height = 1, width = 1, preview = { border = 'noborder', layout = 'vertical' } },
        defaults = { formatter = 'path.filename_first' },
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
    cmd = { 'FzfLua' },
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
          require("fzf-lua").files({ search = text })
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
      }
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
      vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        callback = function()
          vim.lsp.buf.format()
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
    'stevearc/conform.nvim',
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          html = { { "prettierd" } },
          javascript = { { "prettierd" } },
          javascriptreact = { { "prettierd" } },
          markdown = { { "prettierd" } },
          typescript = { { "prettierd" } },
          typescriptreact = { { "prettierd" } },
          ["*"] = { "trim_whitespace" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters = {
          prettierd = {
            condition = function()
              return vim.loop.fs_realpath(".prettierrc.js") ~= nil or vim.loop.fs_realpath(".prettierrc.mjs") ~= nil
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
            function(client, bufnr)
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
  'windwp/nvim-autopairs',
  { "rafamadriz/friendly-snippets" },
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
      'onsails/lspkind.nvim',
    },
    config = function()
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local cmp = require 'cmp'
      local lspkind = require('lspkind')

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
          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" }),
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end
        }, { "i", "s" }),
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
          { name = 'vsnip',    priority = 6 },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol_text',  -- show only symbol annotations
            maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          })
        }

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
    'rmagatti/gx-extended.nvim',
    config = function()
      require('gx-extended').setup ({
        open_fn = require'lazy.util'.open,
      })
    end
  },
  'jbyuki/venn.nvim',
})

require('misc')
require('highlights')
require('todo')
require('keymaps')
require('commands')
