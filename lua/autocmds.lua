require "nvchad.autocmds"

-- Autocomplétion dadbod pour les fichiers SQL
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plpgsql" },
  callback = function()
    local cmp = require "cmp"
    cmp.setup.buffer {
      sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" },
      },
    }
  end,
})
