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
    php = { "php_cs_fixer" },
  },
  formatters = {
    php_cs_fixer = {
      command = vim.fn.stdpath "data" .. "/mason/bin/php-cs-fixer",
    },
  },
  format_on_save = {
    timeout_ms = 3000,
    lsp_fallback = true,
  },
}

return options
