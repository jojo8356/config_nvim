-- NvChad v2.5 récent utilise les nouvelles APIs `vim.lsp.config/enable`
-- disponibles à partir de Neovim 0.11. Cette machine est en 0.10.4, donc on
-- garde un fallback compatible 0.10 via `lspconfig[server].setup` plus bas.
if vim.lsp.config and vim.lsp.enable then
  require("nvchad.configs.lspconfig").defaults()
end

local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
local lspconfig = require "lspconfig"
local util = require "lspconfig.util"
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local function exe(name)
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

local function python_root_dir(fname)
  return util.root_pattern(unpack(python_root_markers))(fname) or vim.fn.getcwd()
end

local function root_pattern(...)
  return util.root_pattern(...)
end

local function setup_server(name, opts)
  if lspconfig[name] then
    opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})
    lspconfig[name].setup(opts)
  end
end

local function setup_lsp()
  -- PHP
  setup_server("phpactor", {
    cmd = { exe "phpactor", "language-server" },
    filetypes = { "php" },
    root_dir = root_pattern("composer.json", ".phpactor.json", ".phpactor.yml", ".git"),
  })

  -- Intelephense est excellent pour l'indexation/autocomplétion de gros projets.
  -- Phpactor reste activé pour ses refactorings/code actions open-source.
  if vim.fn.executable(exe "intelephense") == 1 then
    setup_server("intelephense", {
      cmd = { exe "intelephense", "--stdio" },
      filetypes = { "php" },
      root_dir = root_pattern("composer.json", ".git"),
      init_options = {
        licenceKey = vim.env.INTELEPHENSE_LICENSE_KEY,
      },
      settings = {
        intelephense = {
          files = {
            maxSize = 5000000,
            associations = { "*.php", "*.phtml", "*.blade.php" },
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

  -- Web
  setup_server("html", {
    cmd = { "/home/jojokes/.local/share/pnpm/vscode-html-language-server", "--stdio" },
    filetypes = { "html", "templ", "htmldjango" },
  })

  setup_server("cssls", {
    cmd = { "/home/jojokes/.local/share/pnpm/vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
  })

  setup_server("tailwindcss", {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = { "html", "css", "javascriptreact", "typescriptreact", "vue", "svelte", "php", "blade" },
    root_dir = root_pattern("tailwind.config.js", "tailwind.config.ts", "postcss.config.js", ".git"),
  })

  setup_server("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "typescript.tsx" },
    root_dir = root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
  })

  -- Python
  setup_server("basedpyright", {
    cmd = { exe "basedpyright-langserver", "--stdio" },
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

  setup_server("ruff", {
    cmd = { exe "ruff", "server" },
    filetypes = { "python" },
    root_dir = python_root_dir,
    settings = {
      ruff = {
        lint = { enable = true },
      },
    },
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  })

  -- SQL
  setup_server("sqls", {
    cmd = { exe "sqls" },
    filetypes = { "sql", "mysql", "plpgsql" },
    root_dir = root_pattern(".git"),
  })

  -- Dart
  setup_server("dartls", {
    cmd = { "/home/jojokes/Applications/flutter/bin/dart", "language-server", "--protocol=lsp" },
    filetypes = { "dart" },
    root_dir = root_pattern("pubspec.yaml", ".git"),
  })
end

setup_lsp()

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
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
  callback = function()
    if vim.fn.executable "emmet-language-server" ~= 1 then
      return
    end

    vim.lsp.start {
      name = "emmet-language-server",
      cmd = { "emmet-language-server", "--stdio" },
      root_dir = vim.fs.root(0, { ".git", "package.json" }) or vim.fn.getcwd(),
    }
  end,
})

require("substitute").setup()

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    require("conform").format { bufnr = args.buf }
  end,
})

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
