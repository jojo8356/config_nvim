local lint = require "lint"

local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

lint.linters_by_ft = {
  php = { "phpstan" },
}

lint.linters.phpstan.cmd = mason_bin .. "/phpstan"
lint.linters.phpstan.args = {
  "analyse",
  "--error-format",
  "raw",
  "--no-progress",
  "--memory-limit",
  "1G",
}

local lint_group = vim.api.nvim_create_augroup("user_lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_group,
  callback = function()
    require("lint").try_lint()
  end,
})
