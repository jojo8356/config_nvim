-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",

  -- Règle NvChad : les couleurs passent par chadrc, JAMAIS par un nvim_set_hl() posé dans
  -- options.lua. base46 compile ces tables dans ~/.local/share/nvim/base46/*.bf puis les
  -- rejoue à chaque chargement de thème (<leader>th, base46.toggle_theme) => ça ne se fait plus
  -- écraser. Et les valeurs peuvent être des noms de la palette ("grey_fg", "black2"...),
  -- donc elles suivent le thème clair/sombre au lieu d'un hex en dur.
  --
  --   hl_add      -> groupes que NvChad/base46 ne définit PAS (nouveau nom)
  --   hl_override -> groupes déjà définis par base46 (Comment, Folded, @keyword...)
  hl_add = {
    -- nvim-ufo (lua/configs/ufo.lua) : tirets + compteur de la ligne de pli.
    -- ufo fait `hi default link UfoFoldedEllipsis Comment` ; notre définition gagne
    -- car elle n'est pas "default". bg = "black2" = le bg que base46 donne à Folded,
    -- sinon le fond de la ligne de pli se coupe au milieu.
    UfoFoldedEllipsis = { fg = "grey_fg", bg = "black2" },

    -- Fond des lignes portant un diagnostic : utilisé par vim.diagnostic.config()
    -- dans lua/options.lua (signs.linehl). Avant, c'était 2 nvim_set_hl() en dur ici,
    -- du coup virés par base46 au premier changement de thème.
    -- Pour un rendu qui suit le thème, remplacer l'hex par { "red", -80 } / { "yellow", -80 }
    -- (base46 accepte { nom_de_couleur, pourcentage_de_lightness }).
    DiagnosticLineError = { bg = "#3a1f1f" },
    DiagnosticLineWarn = { bg = "#332b18" },
  },

  -- hl_override = {
  --   Comment = { italic = true },
  --   ["@comment"] = { italic = true },
  --   Folded = { bg = "black2", fg = "light_grey" },
  -- },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

M.colorify = {
  enabled = true,
  mode = "bg", -- fg, bg, virtual
  virt_text = "󱓻 ",
  highlight = { hex = true, lspvars = true },
}

return M
