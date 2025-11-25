require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

map("i", "jk", "<ESC>")

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)

map("n", "gs", function()
  vim.cmd("vsplit")
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
  if content:match('"react"%s*:') or content:match('"react%-dom"%s*:') then
    return true
  end

  return false
end

map("n", "<F5>", function()
  if is_react_project() then
    vim.cmd("tabnew | term pnpm run dev")
    return
  end
  print("❌ Pas un projet React")
end, { desc = "Launch pnpm dev (React only)" })

-- Exchange
map("n", "sx", require("substitute.exchange").operator)
map("n", "sxx", require("substitute.exchange").line)
map("x", "X", require("substitute.exchange").visual)
map("n", "sxc", require("substitute.exchange").cancel)
