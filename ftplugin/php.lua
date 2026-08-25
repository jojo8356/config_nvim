vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end

local function root()
  return vim.fs.root(0, {
    "composer.json",
    "phpunit.xml",
    "phpunit.xml.dist",
    "pest.php",
    "artisan",
    ".git",
  }) or vim.fn.getcwd()
end

local function executable(path)
  return vim.fn.executable(path) == 1
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function term(cmd, cwd)
  vim.cmd "tabnew"
  vim.cmd("lcd " .. vim.fn.fnameescape(cwd or root()))
  vim.fn.termopen(cmd, { cwd = cwd or root() })
  vim.cmd "startinsert"
end

local function local_bin(name)
  return root() .. "/vendor/bin/" .. name
end

local function phpunit_cmd()
  if executable(local_bin "pest") then
    return local_bin "pest"
  end
  if executable(local_bin "phpunit") then
    return local_bin "phpunit"
  end
  if executable "pest" then
    return "pest"
  end
  return "phpunit"
end

local function composer_cmd(args)
  if not executable "composer" then
    vim.notify("Composer introuvable dans PATH", vim.log.levels.WARN)
    return
  end
  term("composer " .. args, root())
end

local function artisan_cmd(args)
  local artisan = root() .. "/artisan"
  if not file_exists(artisan) then
    vim.notify("Pas de fichier artisan dans ce projet", vim.log.levels.WARN)
    return
  end
  term("php artisan " .. args, root())
end

local function run_neotest_current()
  local ok, neotest = pcall(require, "neotest")
  if ok then
    neotest.run.run()
  else
    term(phpunit_cmd() .. " " .. vim.fn.shellescape(vim.fn.expand "%:p"), root())
  end
end

local function run_neotest_file()
  local ok, neotest = pcall(require, "neotest")
  if ok then
    neotest.run.run(vim.fn.expand "%:p")
  else
    term(phpunit_cmd() .. " " .. vim.fn.shellescape(vim.fn.expand "%:p"), root())
  end
end

local function run_php_file()
  term("php " .. vim.fn.shellescape(vim.fn.expand "%:p"), root())
end

local function run_phpstan()
  local cmd = executable(local_bin "phpstan") and local_bin "phpstan"
    or (executable(vim.fn.stdpath "data" .. "/mason/bin/phpstan") and vim.fn.stdpath "data" .. "/mason/bin/phpstan" or "phpstan")
  term(cmd .. " analyse --memory-limit=1G", root())
end

local function run_php_cs_fixer()
  local fixer = executable(local_bin "php-cs-fixer") and local_bin "php-cs-fixer"
    or (executable(vim.fn.stdpath "data" .. "/mason/bin/php-cs-fixer") and vim.fn.stdpath "data" .. "/mason/bin/php-cs-fixer" or "php-cs-fixer")
  term(fixer .. " fix " .. vim.fn.shellescape(vim.fn.expand "%:p"), root())
end

-- Debug PHP via Xdebug + vscode-php-debug/php-debug-adapter installé par Mason.
local ok_dap, dap = pcall(require, "dap")
if ok_dap then
  local adapter = vim.fn.stdpath "data" .. "/mason/bin/php-debug-adapter"
  if executable(adapter) and not dap.adapters.php then
    dap.adapters.php = {
      type = "executable",
      command = adapter,
    }
  end

  dap.configurations.php = dap.configurations.php or {
    {
      type = "php",
      request = "launch",
      name = "Listen for Xdebug",
      port = 9003,
      pathMappings = {
        ["/var/www/html"] = root(),
      },
    },
    {
      type = "php",
      request = "launch",
      name = "Run current script with Xdebug",
      program = "${file}",
      cwd = "${fileDirname}",
      port = 0,
      runtimeExecutable = "php",
    },
  }
end

vim.api.nvim_create_user_command("PhpRun", run_php_file, { desc = "PHP: run current file" })
vim.api.nvim_create_user_command("PhpTest", run_neotest_current, { desc = "PHP: run nearest test" })
vim.api.nvim_create_user_command("PhpTestFile", run_neotest_file, { desc = "PHP: run current test file" })
vim.api.nvim_create_user_command("PhpStan", run_phpstan, { desc = "PHP: run PHPStan" })
vim.api.nvim_create_user_command("PhpFix", run_php_cs_fixer, { desc = "PHP: php-cs-fixer current file" })
vim.api.nvim_create_user_command("ComposerInstall", function() composer_cmd "install" end, { desc = "Composer install" })
vim.api.nvim_create_user_command("ComposerUpdate", function() composer_cmd "update" end, { desc = "Composer update" })
vim.api.nvim_create_user_command("Artisan", function(opts) artisan_cmd(opts.args) end, {
  desc = "Laravel Artisan",
  nargs = "*",
})

map("n", "<leader>pr", run_php_file, "PHP: run file")
map("n", "<leader>pt", run_neotest_current, "PHP: test nearest")
map("n", "<leader>pT", run_neotest_file, "PHP: test file")
map("n", "<leader>ps", run_phpstan, "PHP: PHPStan")
map("n", "<leader>pf", run_php_cs_fixer, "PHP: fix file")
map("n", "<leader>pc", function() composer_cmd "install" end, "PHP: composer install")
map("n", "<leader>pa", function()
  artisan_cmd(vim.fn.input "artisan ")
end, "Laravel: artisan")

if ok_dap then
  map("n", "<leader>pd", dap.continue, "PHP: debug continue/listen")
  map("n", "<leader>pb", dap.toggle_breakpoint, "PHP: toggle breakpoint")
end
