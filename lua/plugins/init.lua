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
    opts = {
      servers = {
        tailwindcss = {},
      },
    },
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
    opts = function(_, opts)
      -- original LazyVim kind icon formatter
      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        format_kinds(entry, item) -- add icons
        return require("tailwindcss-colorizer-cmp").formatter(entry, item)
      end
    end,
  },
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    -- optionally, override the default options:
    config = function()
      require("tailwindcss-colorizer-cmp").setup {
        color_square_width = 2,
      }
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require "null-ls"
      null_ls.setup {
        sources = {
          null_ls.builtins.formatting.prettier, -- Prettier
        },
        on_attach = function(client)
          if client.supports_method "textDocument/formatting" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              pattern = "*",
              callback = function()
                vim.lsp.buf.format { async = false }
              end,
            })
          end
        end,
      }
    end,
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
}
