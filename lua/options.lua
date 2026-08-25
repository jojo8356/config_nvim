require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- NvChad disables the optional providers by default. Unset the ones we want.
vim.g.loaded_node_provider = nil
vim.g.loaded_python3_provider = nil
vim.g.loaded_ruby_provider = nil

-- Keep Perl disabled.
vim.g.loaded_perl_provider = 0

local npm_root = vim.fn.trim(vim.fn.system("npm root -g"))
if npm_root ~= "" then
  vim.g.node_host_prog = vim.fn.fnamemodify(npm_root, ":h:h") .. "/bin/neovim-node-host"
end

local diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = "E",
  [vim.diagnostic.severity.WARN] = "W",
  [vim.diagnostic.severity.INFO] = "I",
  [vim.diagnostic.severity.HINT] = "H",
}

vim.api.nvim_set_hl(0, "DiagnosticLineError", { bg = "#3a1f1f" })
vim.api.nvim_set_hl(0, "DiagnosticLineWarn", { bg = "#332b18" })

vim.diagnostic.config {
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  float = {
    border = "rounded",
    source = "always",
  },
  signs = {
    text = diagnostic_signs,
    linehl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticLineError",
      [vim.diagnostic.severity.WARN] = "DiagnosticLineWarn",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
    },
  },
}
