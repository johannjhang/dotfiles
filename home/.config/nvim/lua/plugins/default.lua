return {
  {
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup()
      vim.keymap.set("n", "{", "<CMD>AerialPrev<CR>", { noremap = true })
      vim.keymap.set("n", "}", "<CMD>AerialNext<CR>", { noremap = true })
      vim.keymap.set("n", "<LEADER>ws", "<CMD>AerialOpen right<CR>", { noremap = true })
    end,
  },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  {
    'stevearc/conform.nvim',
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          -- Conform will run multiple formatters sequentially
          python = { "ruff", "black" },
          -- You can customize some of the format options for the filetype (:help conform.format)
          rust = { "rustfmt", lsp_format = "fallback" },
        }
      })
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr({'timeout_ms':2000})"
    end,
    opts = {},
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "gitsigns-blame" },
        callback = function()
          vim.api.nvim_buf_set_keymap(0, "n", "q", "<CMD>q<CR>", { noremap = true, silent = true })
        end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "git" },
        callback = function()
          vim.api.nvim_buf_set_keymap(0, "n", "q", "<CMD>q<CR>", { noremap = true, silent = true })
        end,
      })
      vim.keymap.set("n", "<LEADER>sb", "<CMD>Gitsigns blame<CR>", { noremap = true, silent = true })
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup()
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme  = "solarized_dark" },
      })
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
  },

  {
    'Kicamon/markdown-table-mode.nvim',
    config = function()
      require('markdown-table-mode').setup({
        options = { pad_separator_line = true },
      })
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "rust_analyzer" },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },

  {
    "echasnovski/mini.align",
    config = function()
      require("mini.align").setup({
        mappings = {
          start = "",
          start_with_preview = "|",
        },
      })
    end,
    version = false,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
      require("neo-tree").setup({
        filesystem = {
          follow_current_file = { enabled = true },
        },
        buffers = {
          follow_current_file = { enabled = true },
        },
      })
      vim.keymap.set("n", "<LEADER>wf", "<CMD>Neotree position=left<CR>", { noremap = true })
    end,
    dependencies = {
      { "MunifTanjim/nui.nvim" },
      { "nvim-tree/nvim-web-devicons" },  -- not strictly required, but recommended
      { "nvim-lua/plenary.nvim" },
    },
  },

  {
    "Tsuzat/NeoSolarized.nvim",
    config = function()
      vim.cmd.colorscheme("NeoSolarized")
    end,
    lazy = false,  -- make sure we load this during startup if it is your main colorscheme
  },

  {
    "hrsh7th/nvim-cmp",
    config = function()
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
            -- require("snippy").expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = {
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
          end, { "i", "s" }),

          ["<C-p>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" }),

          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", group_index = 2 },
          { name = "path", group_index = 2 },
          -- { name = "vsnip" }, -- For vsnip users.
          -- { name = "luasnip" }, -- For luasnip users.
          -- { name = "ultisnips" }, -- For ultisnips users.
          -- { name = "snippy" }, -- For snippy users.
        }, {
          { name = "buffer" },
        })
      })

      -- Set configuration for specific filetype.
      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
          { name = "buffer" },
        })
      })

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<C-e>"] = {
            c = function(fallback)
              if cmp.visible() then
                cmp.close()
                cmp.complete()
              else
                fallback()
              end
            end,
          },
        }),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/vim-vsnip" },
    },
    event = "InsertEnter",
  },

  {
    "mrjohannchang/nvim-config-local",
    config = function()
      require("config-local").setup({
        lookup_parents = true,     -- Lookup config files in parent directories
      })
    end,
  },

  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup()
    end,
    event = "VeryLazy",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
  },

  {
    "nvim-telescope/telescope.nvim",
    config = function()
      vim.keymap.set("n", "<LEADER>ff", "<CMD>lua require('telescope.builtin').find_files()<CR>", { noremap = true })
      vim.keymap.set("n", "<LEADER>fh", "<CMD>lua require('telescope.builtin').find_files({ hidden = true })<CR>", { noremap = true })
      vim.keymap.set("n", "<LEADER>fg", "<CMD>lua require('telescope.builtin').live_grep()<CR>", { noremap = true })
      vim.keymap.set("n", "<LEADER>fw", "<CMD>lua require('telescope.builtin').grep_string()<CR>", { noremap = true })
      vim.keymap.set("n", "<LEADER>fb", "<CMD>lua require('telescope.builtin').buffers({ sort_mru = true })<CR>", { noremap = true })

      vim.keymap.set("n", "<LEADER>gd", "<CMD>lua require('telescope.builtin').lsp_definitions({ reuse_win = true })<CR>", { noremap = true })
      vim.keymap.set("n", "<LEADER>gr", "<CMD>Telescope lsp_references<CR>", { noremap = true })
      vim.keymap.set("n", "<LEADER>gi", "<CMD>lua require('telescope.builtin').lsp_implementations({ reuse_win = true })<CR>", { noremap = true })
      vim.keymap.set("n", "<LEADER>gy", "<CMD>lua require('telescope.builtin').lsp_type_definitions({ reuse_win = true })<CR>", { noremap = true })

      require("telescope").load_extension("recent_files")

      require("telescope").setup({
        defaults = {
          -- Default configuration for telescope goes here:
          -- config_key = value,
          -- ..
          -- initial_mode = "normal",
          mappings = {
            n = {
              ["<ESC>"] = false,
              ["dd"] = require("telescope.actions").delete_buffer,
              ["q"] = require("telescope.actions").close,
              ["<C-c>"] = require("telescope.actions").close,
              ["<C-n>"] = require("telescope.actions").move_selection_next,
              ["<C-p>"] = require("telescope.actions").move_selection_previous,
            },
          },
        },
        extensions = {
          undo = {
            mappings = {
              i = {
                ["<CR>"] = require("telescope-undo.actions").restore,
              },
              n = {
                ["<CR>"] = require("telescope-undo.actions").restore,
              },
            },
          },
        },
        vim.keymap.set("n", "<LEADER>fu", "<CMD>lua require('telescope').extensions.undo.undo()<CR>", { noremap = true }),
        vim.keymap.set("n", "<LEADER>fr", "<CMD>lua require('telescope').extensions.recent_files.pick()<CR>", { noremap = true }),
      })

      require("telescope").load_extension("undo")
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "smartpde/telescope-recent-files" },
      { "debugloop/telescope-undo.nvim" },
    },
  },

  -- LSP related {
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
      vim.keymap.set("n", "<LEADER>rn", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true })
    end,
    dependencies = {
      { "mason-org/mason-lspconfig.nvim" },
    }
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    config = function()
      require("lazydev").setup()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        command = "setlocal shiftwidth=2 softtabstop=2 tabstop=2"
      })
    end,
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true },
      { "mason-org/mason-lspconfig.nvim" },
    },
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = {
      { "mason-org/mason-lspconfig.nvim" },
    },
    keys = {
      {
        "<LEADER>xx",
        "<CMD>Trouble diagnostics toggle<CR>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<LEADER>xX",
        "<CMD>Trouble diagnostics toggle filter.buf=0<CR>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<LEADER>cs",
        "<CMD>Trouble symbols toggle focus=false<CR>",
        desc = "Symbols (Trouble)",
      },
      {
        "<LEADER>cl",
        "<CMD>Trouble lsp toggle focus=false win.position=right<CR>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<LEADER>xL",
        "<CMD>Trouble loclist toggle<CR>",
        desc = "Location List (Trouble)",
      },
      {
        "<LEADER>xQ",
        "<CMD>Trouble qflist toggle<CR>",
        desc = "Quickfix List (Trouble)",
      },
    },
    opts = {}, -- for default options, refer to the configuration section for custom setup.
  },
  -- } LSP related
}
