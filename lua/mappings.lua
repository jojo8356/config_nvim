require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

map("i", "jk", "<ESC>")

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)

map("n", "gs", function()
  vim.cmd "vsplit"
  vim.lsp.buf.definition()
end, { desc = "Go to definition in horizontal split" })

local function is_react_project()
  -- Vérifie package.json
  local pkg = vim.fn.findfile("package.json", ".;")
  if pkg == "" then
    return false
  end

  -- Lit le fichier
  local json = vim.fn.readfile(pkg)
  local content = table.concat(json, "\n")

  -- Cherche React dans le fichier
  if content:match '"react"%s*:' or content:match '"react%-dom"%s*:' then
    return true
  end

  return false
end

map("n", "<F5>", function()
  if is_react_project() then
    vim.cmd "tabnew | term pnpm run dev"
    return
  end
  print "❌ Pas un projet React"
end, { desc = "Launch pnpm dev (React only)" })

-- Exchange
map("n", "sx", require("substitute.exchange").operator)
map("n", "sxx", require("substitute.exchange").line)
map("x", "X", require("substitute.exchange").visual)
map("n", "sxc", require("substitute.exchange").cancel)

-- Normal-mode commands
vim.keymap.set("n", "<A-j>", ":MoveLine(1)<CR>", opts)
vim.keymap.set("n", "<A-k>", ":MoveLine(-1)<CR>", opts)
vim.keymap.set("n", "<A-h>", ":MoveHChar(-1)<CR>", opts)
vim.keymap.set("n", "<A-l>", ":MoveHChar(1)<CR>", opts)
vim.keymap.set("n", "<leader>wf", ":MoveWord(1)<CR>", opts)
vim.keymap.set("n", "<leader>wb", ":MoveWord(-1)<CR>", opts)

-- Visual-mode commands
vim.keymap.set("v", "<A-j>", ":MoveBlock(1)<CR>", opts)
vim.keymap.set("v", "<A-k>", ":MoveBlock(-1)<CR>", opts)
vim.keymap.set("v", "<A-h>", ":MoveHBlock(-1)<CR>", opts)
vim.keymap.set("v", "<A-l>", ":MoveHBlock(1)<CR>", opts)

vim.keymap.set("n", "<C-l>", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle line numbers" })

vim.keymap.set("n", "<leader>rn", function()
  -- it returns success status, thus you can fallback like so
  if not require("ts-autotag").rename() then
    vim.lsp.buf.rename()
  end
end)

vim.api.nvim_set_keymap("n", "<leader>n", ":e ~/.config/nvim/notes.md<CR>", { noremap = true, silent = true })

_G.no_clipboard = false

-- toggle fonction
function ToggleNoClipboard()
  _G.no_clipboard = not _G.no_clipboard
  if _G.no_clipboard then
    print "Mode: supprimer sans mémoire activé"
  else
    print "Mode: suppression normale activée"
  end
end

-- mapping Ctrl+m pour toggle
vim.api.nvim_set_keymap("n", "<C-m>", ":lua ToggleNoClipboard()<CR>", opts)

-- redéfinir d et x pour utiliser registre noir si toggle actif
vim.keymap.set({ "n", "x" }, "d", function()
  if _G.no_clipboard then
    return [["_d]]
  else
    return "d"
  end
end, { expr = true, noremap = true })

vim.keymap.set({ "n", "x" }, "x", function()
  if _G.no_clipboard then
    return [["_x]]
  else
    return "x"
  end
end, { expr = true, noremap = true })

vim.api.nvim_set_keymap("n", "MP", "dith<C-v>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>d", "<Plug>(nvim-surround-delete)", { desc = "Delete surrounding tag" })
vim.keymap.set("n", "<leader>ia", ":TSLspImportAll<CR>", { desc = "Import missing all" })
