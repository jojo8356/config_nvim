require "nvchad.autocmds"

-- Sauvegarde/restauration de l'état des plis (folds) par fichier, indépendamment
-- des sessions (auto-session s'en charge déjà au niveau du projet).
-- Principe classique "mkview / loadview" : à chaque save (et quand on quitte le
-- buffer), on écrit un fichier de vue (plis + position du curseur) ; à la
-- réouverture, on le recharge pour retrouver l'état propre du workspace.
vim.opt.viewoptions = { "folds", "cursor" }

local view_group = vim.api.nvim_create_augroup("PersistFoldView", { clear = true })

local function is_normal_file_buf(buf)
  buf = buf or 0
  return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufWinLeave" }, {
  group = view_group,
  pattern = "?*",
  desc = "Sauver l'état des plis du buffer (mkview)",
  callback = function(args)
    if is_normal_file_buf(args.buf) then
      vim.cmd "silent! mkview"
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = view_group,
  pattern = "?*",
  desc = "Restaurer l'état des plis du buffer (loadview)",
  callback = function(args)
    if is_normal_file_buf(args.buf) then
      vim.cmd "silent! loadview"
    end
  end,
})

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
