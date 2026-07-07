return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "romus204/referencer.nvim",
    config = function()
      require("referencer").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "dart", "html", "java", "php", "phpdoc", "python", "sql" },
        highlight = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["a t"] = "@tag.outer",
              ["i t"] = "@tag.inner",
            },
          },
        },
      }
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,

    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      -- log_level = 'debug',
    },
  },
  {
    "olrtg/nvim-emmet",
    config = function()
      vim.keymap.set({ "n", "v" }, "xe", require("nvim-emmet").wrap_with_abbreviation)
    end,
  },
  {
    "gbprod/substitute.nvim",
    opts = {},
  },
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
  },
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()

      -- packages à installer automatiquement
      local ensure_installed = {
        "prettier",
        "prettierd",
        "lua-language-server",
        "typescript-language-server",

        "jdtls",
        "java-debug-adapter",
        "java-test",
        "google-java-format",
        "stylua",
        "eslint_d",
        "black",
        "ruff",
        "mypy",
        "basedpyright",
        "debugpy",
        "sqls",
        "sql-formatter",
        "phpactor",
        "php-cs-fixer",
        "phpstan",
      }

      local mr = require "mason-registry"
      for _, pkg in ipairs(ensure_installed) do
        local p = mr.get_package(pkg)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },
  {
    "fedepujol/move.nvim",
    opts = {
      --- Config
    },
  },
  { "tronikelis/ts-autotag.nvim" },
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "ys",
          normal_cur = "yss",
          normal_line = "yS",
          normal_cur_line = "ySS",
          visual = "S",
          visual_line = "gS",
          delete = "ds",
          change = "cs",
          change_line = "cS",
        },
      }
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    ft = "python",
    config = function()
      require "configs.none-ls"
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lint"
    end,
  },

  -- Python
  {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    opts = {
      auto_refresh = true,
      stay_on_this_version = true,
    },
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Python: Select venv" },
    },
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-python" {
            dap = { justMyCode = false },
            runner = "pytest",
            python = ".venv/bin/python",
          },
        },
      }
    end,
  },

  -- Java
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    config = function()
      local dap = require "dap"
      -- UI basique pour le debug
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
      end, { desc = "Debug: Conditional breakpoint" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    lazy = true,
    config = function()
      local dapui = require "dapui"
      dapui.setup()
      local dap = require "dap"
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
    end,
  },

  -- PostgreSQL / SQL
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod" },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plpgsql" } },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "DB: Toggle UI" },
      { "<leader>da", "<cmd>DBUIAddConnection<cr>", desc = "DB: Add connection" },
      { "<leader>df", "<cmd>DBUIFindBuffer<cr>", desc = "DB: Find buffer" },
    },
    init = function()
      vim.g.db_ui_use_nerd_font_icons = 1
      vim.g.db_ui_save_location = vim.fn.expand "~/.local/share/nvim/db_ui"
      vim.g.db_ui_execute_on_save = false
    end,
  },

  -- Helix-style select-first editing
  {
    "kak.nvim",
    url = "https://codeberg.org/mirge/kak.nvim.git",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("kak").setup(opts)

      vim.keymap.set("n", "G", function()
        local count = vim.v.count
        if count > 0 then
          vim.cmd("normal! " .. count .. "G")
        else
          vim.cmd "normal! G"
        end
      end, { desc = "Go to line or end of file" })
    end,
  },
}
