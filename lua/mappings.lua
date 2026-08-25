require "nvchad.mappings"

-- add yours here

vim.api.nvim_create_user_command("Reload", function()
  vim.cmd("source " .. vim.fn.stdpath "config" .. "/lua/mappings.lua")
  print "Mappings rechargés"
end, { desc = "Reload mappings.lua" })

local map = vim.keymap.set
local maven = require "configs.maven"

map("n", ";", ":", { desc = "CMD enter command mode" })

map("i", "jk", "<ESC>")
map("n", "<leader>a", "ggVG", { desc = "Select all content" })

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
  local ft = vim.bo.filetype
  if ft == "java" then
    local ok, dap = pcall(require, "dap")
    if ok then
      dap.continue()
      return
    end

    if maven.is_maven_project(0) then
      maven.exec_main()
      return
    end

    local file = vim.fn.expand "%:p"
    vim.cmd(
      "tabnew | term javac "
        .. vim.fn.shellescape(file)
        .. " && java -cp "
        .. vim.fn.shellescape(vim.fn.expand "%:p:h")
        .. " "
        .. vim.fn.shellescape(vim.fn.expand "%:t:r")
    )
    return
  end
  if ft == "python" then
    if package.loaded["dap"] then
      require("dap").continue()
    else
      local file = vim.fn.expand "%:p"
      vim.cmd("tabnew | term python3 " .. file)
    end
    return
  end
  if is_react_project() then
    vim.cmd "tabnew | term pnpm run dev"
    return
  end
  print "Pas un projet supporté"
end, { desc = "Run project (Java/Python/React)" })

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

vim.keymap.set("n", "<leader>qs", "<cmd>AutoSession save<CR>", { desc = "Session save" })
vim.keymap.set("n", "<leader>qr", "<cmd>AutoSession restore<CR>", { desc = "Session restore" })
vim.keymap.set("n", "<leader>qf", "<cmd>AutoSession search<CR>", { desc = "Session search" })

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
  return _G.no_clipboard and [["_d]] or "d"
end, { expr = true, noremap = true })

vim.keymap.set("n", "dd", function()
  return _G.no_clipboard and [["_dd]] or "dd"
end, { expr = true, noremap = true })

vim.keymap.set({ "n", "x" }, "x", function()
  return _G.no_clipboard and [["_x]] or "x"
end, { expr = true, noremap = true })

vim.api.nvim_set_keymap("n", "MP", "dith<C-v>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>d", "<Plug>(nvim-surround-delete)", { desc = "Delete surrounding tag" })
vim.keymap.set("n", "<leader>ia", ":TSLspImportAll<CR>", { desc = "Import missing all" })
