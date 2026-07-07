local opts = { buffer = 0, silent = true }
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

-- Trouver le python du venv ou le système
local function get_python()
  local venv = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX"
  if venv then
    return venv .. "/bin/python"
  end
  -- Chercher un .venv local
  local local_venv = vim.fn.finddir(".venv", ".;")
  if local_venv ~= "" then
    return local_venv .. "/bin/python"
  end
  return "python3"
end

local function open_term(cmd)
  vim.cmd "tabnew"
  vim.fn.termopen(cmd)
  vim.cmd "startinsert"
end

-- Configurer debugpy (DAP)
local dap_ok, dap = pcall(require, "dap")
if dap_ok and not dap.adapters.python then
  local debugpy_adapter = mason_bin .. "/debugpy-adapter"
  local fallback_python = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"

  dap.adapters.python = {
    type = "executable",
    command = vim.fn.executable(debugpy_adapter) == 1 and debugpy_adapter or fallback_python,
    args = vim.fn.executable(debugpy_adapter) == 1 and nil or { "-m", "debugpy.adapter" },
  }

  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Run file",
      program = "${file}",
      pythonPath = get_python,
    },
    {
      type = "python",
      request = "launch",
      name = "Run file with args",
      program = "${file}",
      pythonPath = get_python,
      args = function()
        local input = vim.fn.input "Arguments: "
        return vim.split(input, " ", { trimempty = true })
      end,
    },
    {
      type = "python",
      request = "launch",
      name = "Run pytest",
      module = "pytest",
      pythonPath = get_python,
      args = { "${file}", "-v" },
    },
  },

  -- Charger dap-ui si disponible
  pcall(function()
    require("dapui").setup()
  end)
end

-- Keybindings Python
vim.keymap.set("n", "<leader>pr", function()
  local file = vim.fn.expand "%:p"
  open_term { get_python(), file }
end, vim.tbl_extend("force", opts, { desc = "Python: Run file" }))

vim.keymap.set("n", "<leader>pt", function()
  local file = vim.fn.expand "%:p"
  open_term { get_python(), "-m", "pytest", file, "-v" }
end, vim.tbl_extend("force", opts, { desc = "Python: Run pytest on file" }))

vim.keymap.set("n", "<leader>pT", function()
  open_term { get_python(), "-m", "pytest", "-v" }
end, vim.tbl_extend("force", opts, { desc = "Python: Run all tests" }))

vim.keymap.set("n", "<leader>pd", function()
  if dap_ok then
    dap.continue()
  else
    print "nvim-dap non chargé"
  end
end, vim.tbl_extend("force", opts, { desc = "Python: Debug" }))

vim.keymap.set("n", "<leader>pm", function()
  local file = vim.fn.expand "%:p"
  open_term { get_python(), "-m", "mypy", file }
end, vim.tbl_extend("force", opts, { desc = "Python: Mypy check" }))

-- Neotest keybindings
vim.keymap.set("n", "<leader>pn", function()
  pcall(function()
    require("neotest").run.run()
  end)
end, vim.tbl_extend("force", opts, { desc = "Python: Neotest run nearest" }))

vim.keymap.set("n", "<leader>pN", function()
  pcall(function()
    require("neotest").run.run(vim.fn.expand "%")
  end)
end, vim.tbl_extend("force", opts, { desc = "Python: Neotest run file" }))

vim.keymap.set("n", "<leader>po", function()
  pcall(function()
    require("neotest").output_panel.toggle()
  end)
end, vim.tbl_extend("force", opts, { desc = "Python: Neotest output" }))
