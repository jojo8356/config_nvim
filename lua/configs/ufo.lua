-- nvim-ufo : rendu de la ligne de pli  ->  { ──── 24 lines ──── }
--
-- Contrat de `fold_virt_text_handler` (source : lua/ufo/decorator.lua,
-- `Decorator.defaultVirtTextHandler`) :
--
--   handler(virtual_text, start_lnum, end_lnum, width, truncate, ctx)
--     virtual_text  { { text, hl_group }, ... } : premiere ligne du pli, DEJA coloree
--     start/end_lnum bornes du pli (même base) -> end - start     = lignes masquées
--                                               -> end - start + 1 = lignes totales du pli
--     width         largeur dispo pour le foldtext (fenêtre - 'number' - 'foldcolumn'...)
--     truncate(t,w) helper ufo : coupe t à la largeur display w, PEUT renvoyer plus court que w
--     ctx           { bufnr, winid, text, get_fold_kind, get_fold_virt_text }
--
-- Les 4 pieges qui rendent d'habitude le résultat moche (ou rouge) :
--   1. ufo met le résultat EN CACHE par (winid, lnum) et ne le recalcule que si la largeur
--      change : un handler qui dépend d'un état global ne se rafraîchit pas tout seul
--      -> `:UfoAttach` ou `:redraw` après modification.
--   2. `truncate()` pouvant rendre plus étroit que demandé, il faut payer le padding
--      soi-même, sinon le compteur n'arrive pas en fin de ligne (et le fond s'arrête avant).
--   3. une erreur dans le handler => "!Error in user's handler" affiché à la place du foldtext
--      -> d'où les pcall() autour de tout ce qui vient de l'extérieur (ctx.get_fold_kind).
--   4. aucune couleur en dur (#..) ici : les groupes sont déclarés dans `base46.hl_add`
--      (lua/chadrc.lua), le seul endroit qui survit à un changement de thème / reload base46.

-- Garde les couleurs produites par Treesitter et reprend la couleur du linter
-- lorsqu'un diagnostic se trouve dans le pli. Sans ce handler, ufo utilise
-- `Folded`/`Comment` pour toute la ligne, ce qui la rend uniformément grise.
local function fold_virt_text_handler(virtual_text, start_lnum, end_lnum, width, truncate)
  local suffix = (" 󰁅 %d lignes "):format(end_lnum - start_lnum + 1)
  local suffix_width = vim.fn.strdisplaywidth(suffix)
  local target_width = math.max(width - suffix_width, 0)
  local result = {}
  local current_width = 0

  -- Utilise les groupes fournis par ufo (Treesitter quand disponibles) sans
  -- appeler d'API optionnelle : cela évite de casser le rendu selon la version
  -- de Neovim/Treesitter installée.
  for _, chunk in ipairs(virtual_text) do
    -- Le groupe Folded de certains thèmes est gris et écrase les couleurs
    -- reçues par ufo. Pour que le résumé ait le même contraste que le code,
    -- force le texte du pli à utiliser Normal (le suffixe reste séparé).
    local text, hl = chunk[1], "Normal"
    local remaining = target_width - current_width
    if remaining <= 0 then break end
    local text_width = vim.fn.strdisplaywidth(text)
    if text_width <= remaining then
      result[#result + 1] = { text, hl }
      current_width = current_width + text_width
    else
      result[#result + 1] = { truncate(text, remaining), hl }
      current_width = target_width
      break
    end
  end

  result[#result + 1] = { string.rep(" ", math.max(target_width - current_width, 0)), "Normal" }
  result[#result + 1] = { suffix, "UfoFoldedEllipsis" }
  return result
end

return {
  -- indispensable pour que ce soit NOTRE handler qui dessine la ligne de pli
  override_foldtext = true,
  fold_virt_text_handler = fold_virt_text_handler,

  -- 'treesitter' lit queries/<ft>/folds.scm (@fold), 'indent' sert de filet
  provider_selector = function()
    return { "treesitter", "indent" }
  end,
}
