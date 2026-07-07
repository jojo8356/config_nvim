local null_ls = require "null-ls"
local methods = require "null-ls.methods"

local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

null_ls.setup {
  debounce = 500,
  default_timeout = 10000,
  sources = {
    -- Mypy est volontairement lancé à la sauvegarde : c'est plus stable
    -- que de type-checker tout le projet à chaque frappe.
    null_ls.builtins.diagnostics.mypy.with {
      method = methods.internal.DIAGNOSTICS_ON_SAVE,
      command = mason_bin .. "/mypy",
      extra_args = function()
        local venv = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX"
        if venv then
          return { "--python-executable", venv .. "/bin/python" }
        end
        return {}
      end,
      diagnostics_postprocess = function(diagnostic)
        diagnostic.source = "mypy"
      end,
    },
  },
}
