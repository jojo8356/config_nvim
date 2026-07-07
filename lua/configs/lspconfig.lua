require("nvchad.configs.lspconfig").defaults()

local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

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

local function python_root_dir(bufnr, on_dir)
  on_dir(vim.fs.root(bufnr, python_root_markers) or vim.fn.getcwd())
end

local function setup_lsp()
  -- PHP
  vim.lsp.config("phpactor", {
    cmd = { exe "phpactor", "language-server" },
    filetypes = { "php" },
    root_markers = { "composer.json", ".phpactor.json", ".phpactor.yml", ".git" },
  })
  vim.lsp.enable "phpactor"

  -- Web
  vim.lsp.config("html", {
    cmd = { "/home/jojokes/.local/share/pnpm/vscode-html-language-server", "--stdio" },
    filetypes = { "html", "templ", "htmldjango" },
  })
  vim.lsp.enable "html"

  vim.lsp.config("cssls", {
    cmd = { "/home/jojokes/.local/share/pnpm/vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
  })
  vim.lsp.enable "cssls"

  vim.lsp.config("tailwindcss", {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = { "html", "css", "javascriptreact", "typescriptreact", "vue", "svelte" },
    root_markers = { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", ".git" },
  })
  vim.lsp.enable "tailwindcss"

  vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "typescript.tsx" },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  })
  vim.lsp.enable "ts_ls"

  -- Python
  vim.lsp.config("basedpyright", {
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
  vim.lsp.enable "basedpyright"

  vim.lsp.config("ruff", {
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
  vim.lsp.enable "ruff"

  -- SQL
  vim.lsp.config("sqls", {
    cmd = { exe "sqls" },
    filetypes = { "sql", "mysql", "plpgsql" },
    root_markers = { ".git" },
  })
  vim.lsp.enable "sqls"

  -- Dart
  vim.lsp.config("dartls", {
    cmd = { "/home/jojokes/Applications/flutter/bin/dart", "language-server", "--protocol=lsp" },
    filetypes = { "dart" },
    root_markers = { "pubspec.yaml", ".git" },
  })
  vim.lsp.enable "dartls"
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
