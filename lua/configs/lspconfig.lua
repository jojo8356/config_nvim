-- ~/.config/nvim/lua/configs/lspconfig.lua
-- Configuration pour NvChad et Neovim 0.12+

require("nvchad.configs.lspconfig").defaults()

local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if has_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local function mason_executable(name)
  return mason_bin .. "/" .. name
end

local python_root_markers = {
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "pyrightconfig.json",
  ".git",
}

-- La nouvelle API root_dir reçoit le numéro du buffer et une callback.
local function python_root_dir(bufnr, on_dir)
  local root = vim.fs.root(bufnr, python_root_markers) or vim.fn.getcwd()
  on_dir(root)
end

local function setup_server(name, options)
  options = options or {}
  options.capabilities = vim.tbl_deep_extend("force", {}, capabilities, options.capabilities or {})

  vim.lsp.config(name, options)
  vim.lsp.enable(name)
end

local function setup_lsp()
  -- PHP : refactorings et actions de code.
  setup_server("phpactor", {
    cmd = { mason_executable "phpactor", "language-server" },
    filetypes = { "php" },
    root_markers = {
      "composer.json",
      ".phpactor.json",
      ".phpactor.yml",
      ".git",
    },
  })

  -- PHP : indexation et autocomplétion.
  if vim.fn.executable(mason_executable "intelephense") == 1 then
    setup_server("intelephense", {
      cmd = { mason_executable "intelephense", "--stdio" },
      filetypes = { "php" },
      root_markers = {
        "composer.json",
        ".git",
      },
      init_options = {
        licenceKey = vim.env.INTELEPHENSE_LICENSE_KEY,
      },
      settings = {
        intelephense = {
          files = {
            maxSize = 5000000,
            associations = {
              "*.php",
              "*.phtml",
              "*.blade.php",
            },
          },
          environment = {
            includePaths = { "vendor" },
          },
          completion = {
            fullyQualifyGlobalConstantsAndFunctions = false,
          },
          diagnostics = {
            enable = true,
          },
        },
      },
    })
  end

  -- HTML.
  setup_server("html", {
    cmd = {
      "/home/jojokes/.local/share/pnpm/vscode-html-language-server",
      "--stdio",
    },
    filetypes = {
      "html",
      "templ",
      "htmldjango",
    },
  })

  -- CSS.
  setup_server("cssls", {
    cmd = {
      "/home/jojokes/.local/share/pnpm/vscode-css-language-server",
      "--stdio",
    },
    filetypes = {
      "css",
      "scss",
      "less",
    },
  })

  -- Tailwind CSS.
  setup_server("tailwindcss", {
    cmd = {
      "tailwindcss-language-server",
      "--stdio",
    },
    filetypes = {
      "html",
      "css",
      "javascriptreact",
      "typescriptreact",
      "vue",
      "svelte",
      "php",
      "blade",
    },
    root_markers = {
      "tailwind.config.js",
      "tailwind.config.ts",
      "postcss.config.js",
      ".git",
    },
  })

  -- JavaScript et TypeScript.
  setup_server("ts_ls", {
    cmd = {
      "typescript-language-server",
      "--stdio",
    },
    filetypes = {
      "typescript",
      "typescriptreact",
      "javascript",
      "javascriptreact",
      "typescript.tsx",
    },
    root_markers = {
      "tsconfig.json",
      "jsconfig.json",
      "package.json",
      ".git",
    },
  })

  -- Python : analyse statique et autocomplétion.
  setup_server("basedpyright", {
    cmd = {
      mason_executable "basedpyright-langserver",
      "--stdio",
    },
    filetypes = { "python" },
    root_dir = python_root_dir,
    settings = {
      basedpyright = {
        analysis = {
          autoImportCompletions = true,
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "standard",
          useLibraryCodeForTypes = true,
        },
      },
    },
  })

  -- Python : lint avec Ruff.
  setup_server("ruff", {
    cmd = {
      mason_executable "ruff",
      "server",
    },
    filetypes = { "python" },
    root_dir = python_root_dir,
    settings = {
      ruff = {
        lint = {
          enable = true,
        },
      },
    },
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  })

  -- SQL.
  setup_server("sqls", {
    cmd = { mason_executable "sqls" },
    filetypes = {
      "sql",
      "mysql",
      "plpgsql",
    },
    root_markers = { ".git" },
  })

  -- Dart et Flutter.
  setup_server("dartls", {
    cmd = {
      "/home/jojokes/Applications/flutter/bin/dart",
      "language-server",
      "--protocol=lsp",
    },
    filetypes = { "dart" },
    root_markers = {
      "pubspec.yaml",
      ".git",
    },
  })

  -- Emmet.
  if vim.fn.executable "emmet-language-server" == 1 then
    setup_server("emmet_language_server", {
      cmd = {
        "emmet-language-server",
        "--stdio",
      },
      filetypes = {
        "css",
        "eruby",
        "html",
        "htmldjango",
        "javascriptreact",
        "less",
        "pug",
        "sass",
        "scss",
        "typescriptreact",
      },
      root_markers = {
        "package.json",
        ".git",
      },
      workspace_required = false,
    })
  end
end

setup_lsp()

-- Substitute.
require("substitute").setup()

-- Formatage automatique avant l'enregistrement.
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    require("conform").format {
      bufnr = args.buf,
    }
  end,
})

-- Déplacement de lignes, blocs et mots.
require("move").setup {
  line = {
    enable = true,
    indent = true,
  },
  block = {
    enable = true,
    indent = true,
  },
  word = {
    enable = true,
  },
  char = {
    enable = false,
  },
}

-- Fermeture automatique des balises.
require("ts-autotag").setup {
  opening_node_types = {
    "tag_start",
    "STag",
    "start_tag",
    "jsx_opening_element",
  },
  identifier_node_types = {
    "tag_name",
    "erroneous_end_tag_name",
    "Name",
    "member_expression",
    "identifier",
    "element_identifier",
  },
  disable_in_macro = true,
  filetypes = {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
    "xml",
    "html",
    "templ",
    "php",
  },
  auto_close = {
    enabled = true,
  },
  auto_rename = {
    enabled = false,
    closing_node_types = {
      "jsx_closing_element",
      "ETag",
      "end_tag",
      "erroneous_end_tag",
      "tag_end",
    },
  },
}
