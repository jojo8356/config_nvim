local options = {
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    json = { "prettier" },
    markdown = { "prettier" },
    python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
    java = { "google-java-format" },
    sql = { "sql_formatter" },
    pgsql = { "sql_formatter" },
    plpgsql = { "sql_formatter" },
    php = { "pint", "php_cs_fixer" },
  },
  formatters = {
    pint = {
      command = function(ctx)
        local source = ctx.bufnr or ctx.buf or ctx.filename or 0
        local root = vim.fs.root(source, { "pint.json", "composer.json", ".git" }) or vim.fn.getcwd()
        local local_pint = root .. "/vendor/bin/pint"
        if vim.fn.executable(local_pint) == 1 then
          return local_pint
        end
        return "pint"
      end,
      args = { "$FILENAME" },
      stdin = false,
      condition = function(ctx)
        local source = ctx.bufnr or ctx.buf or ctx.filename or 0
        local root = vim.fs.root(source, { "pint.json", "composer.json", ".git" }) or vim.fn.getcwd()
        return vim.fn.filereadable(root .. "/pint.json") == 1
          or vim.fn.executable(root .. "/vendor/bin/pint") == 1
          or vim.fn.executable "pint" == 1
      end,
    },
    php_cs_fixer = {
      command = vim.fn.stdpath "data" .. "/mason/bin/php-cs-fixer",
      args = { "fix", "$FILENAME", "--using-cache=no", "--quiet" },
      stdin = false,
    },
  },
  format_on_save = {
    timeout_ms = 3000,
    lsp_fallback = true,
  },
}

return options
