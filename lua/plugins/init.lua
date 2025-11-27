return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
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
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "dart" },
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
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()

      -- packages à installer automatiquement
      local ensure_installed = {
        "prettier",
        "prettierd",
        "lua-language-server",
        "typescript-language-server",
        "dartls",
        "stylua",
        "eslint_d",
        "black",
        "mypy",
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
  { "nvimtools/none-ls.nvim" },
}
