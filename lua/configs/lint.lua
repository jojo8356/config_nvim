local lint = require "lint"

local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

lint.linters_by_ft = {
  php = { "php", "phpstan", "phpcs" },
}

if lint.linters.php then
  lint.linters.php.cmd = "php"
  lint.linters.php.args = { "-l" }
end

lint.linters.phpstan.cmd = mason_bin .. "/phpstan"
lint.linters.phpstan.args = {
  "analyse",
  "--error-format",
  "raw",
  "--no-progress",
  "--memory-limit",
  "1G",
}

if lint.linters.phpcs then
  lint.linters.phpcs.cmd = mason_bin .. "/phpcs"
  lint.linters.phpcs.args = {
    "--report=json",
    "--standard=PSR12",
    "-q",
  }
end

local function executable_linter_names(names)
  local available = {}
  for _, name in ipairs(names) do
    local linter = lint.linters[name]
    local cmd = linter and linter.cmd
    if type(cmd) == "function" then
      cmd = cmd()
    end
    if type(cmd) == "string" and vim.fn.executable(cmd) == 1 then
      if name == "phpcs" then
        vim.fn.system { cmd, "--version" }
        if vim.v.shell_error ~= 0 then
          goto continue
        end
      end
      table.insert(available, name)
    end
    ::continue::
  end
  return available
end

lint.linters_by_ft.php = executable_linter_names(lint.linters_by_ft.php)

local lint_group = vim.api.nvim_create_augroup("user_lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_group,
  callback = function()
    require("lint").try_lint()
  end,
})
