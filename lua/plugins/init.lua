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
    lazy = false,
    build = ":TSUpdate",

    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "lua",
          "dart",
          "html",
          "java",
          "php",
          "phpdoc",
          "python",
          "sql",
          "yaml",
          "json",
        },

        highlight = {
          enable = true,
        },

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
    "kevinhwang91/nvim-ufo",

    main = "ufo",
    lazy = false,
    priority = 1000,

    dependencies = {
      "kevinhwang91/promise-async",
    },

    init = function()
      vim.opt.foldcolumn = "1"
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true
    end,

    opts = function()
      local function fold_text_handler(virtual_text, start_line, end_line, width, truncate)
        local result = {}

        local line_count = end_line - start_line + 1

        local label = line_count == 1 and "ligne" or "lignes"

        local suffix = string.format(" %d %s --}", line_count, label)

        local suffix_width = vim.fn.strdisplaywidth(suffix)

        local available_width = math.max(0, width - suffix_width)

        local current_width = 0

        for _, chunk in ipairs(virtual_text) do
          local text = chunk[1]
          local highlight = chunk[2]

          local chunk_width = vim.fn.strdisplaywidth(text)

          if current_width + chunk_width <= available_width then
            table.insert(result, chunk)

            current_width = current_width + chunk_width
          else
            local remaining = available_width - current_width

            if remaining > 0 then
              local truncated_text = truncate(text, remaining)

              table.insert(result, {
                truncated_text,
                highlight,
              })

              current_width = current_width + vim.fn.strdisplaywidth(truncated_text)
            end

            break
          end
        end

        local padding = math.max(0, available_width - current_width)

        if padding > 0 then
          table.insert(result, {
            string.rep("-", padding),
            "Comment",
          })
        end

        table.insert(result, {
          suffix,
          "Comment",
        })

        return result
      end

      return {
        override_foldtext = true,

        provider_selector = function()
          return {
            "treesitter",
            "indent",
          }
        end,

        fold_virt_text_handler = fold_text_handler,
      }
    end,

    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Ouvrir tous les plis",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Fermer tous les plis",
      },
      {
        "<leader>z",
        "za",
        desc = "Ouvrir/fermer le pli",
      },
    },
  },
  {
    "rmagatti/auto-session",
    lazy = false,

    opts = {
      auto_save = true,
      auto_restore = true,
      auto_restore_last_session = true,
      cwd_change_handling = true,
      args_allow_files_auto_save = true,
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      save_extra_data = require("configs.session").save_extra_data,
      restore_extra_data = require("configs.session").restore_extra_data,
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
    -- Dernière version compatible avec Neovim 0.10.x.
    -- Les versions plus récentes de Telescope exigent Neovim 0.11+.
    "nvim-telescope/telescope.nvim",
    commit = "7dbbcfdd4d1622ee7152b9b18cafbddd712a1fd1",
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
        "composer",
        "phpactor",
        "intelephense",
        "php-cs-fixer",
        "phpstan",
        "phpcs",
        "php-debug-adapter",
      }

      local mr = require "mason-registry"
      for _, pkg in ipairs(ensure_installed) do
        local ok, p = pcall(mr.get_package, pkg)
        if ok and not p:is_installed() then
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
      "olimorris/neotest-phpunit",
    },
    config = function()
      local adapters = {
        require "neotest-python" {
          dap = { justMyCode = false },
          runner = "pytest",
          python = ".venv/bin/python",
        },
      }

      local ok_phpunit, phpunit = pcall(require, "neotest-phpunit")
      if ok_phpunit then
        table.insert(
          adapters,
          phpunit {
            phpunit_cmd = function()
              if vim.fn.filereadable "vendor/bin/pest" == 1 then
                return "vendor/bin/pest"
              end
              if vim.fn.filereadable "vendor/bin/phpunit" == 1 then
                return "vendor/bin/phpunit"
              end
              return "phpunit"
            end,
          }
        )
      end

      require("neotest").setup {
        adapters = adapters,
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
}
