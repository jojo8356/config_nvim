local opts = { buffer = true, silent = true }

-- Exécuter la requête courante (paragraphe) dans dadbod
vim.keymap.set("n", "<leader>sq", "<Plug>(DBUI_ExecuteQuery)", vim.tbl_extend("force", opts, { desc = "SQL: Execute query" }))
vim.keymap.set("v", "<leader>sq", "<Plug>(DBUI_ExecuteQuery)", vim.tbl_extend("force", opts, { desc = "SQL: Execute selection" }))

-- Sauvegarder la requête
vim.keymap.set("n", "<leader>ss", "<Plug>(DBUI_SaveQuery)", vim.tbl_extend("force", opts, { desc = "SQL: Save query" }))

-- Raccourcis sqls (switch connection/database)
vim.keymap.set("n", "<leader>sc", function()
  vim.lsp.buf.execute_command { command = "switchConnections" }
end, vim.tbl_extend("force", opts, { desc = "SQL: Switch connection" }))

vim.keymap.set("n", "<leader>sd", function()
  vim.lsp.buf.execute_command { command = "switchDatabase" }
end, vim.tbl_extend("force", opts, { desc = "SQL: Switch database" }))

-- Options buffer SQL
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true
