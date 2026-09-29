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

return {
  -- indispensable pour que ce soit NOTRE handler qui dessine la ligne de pli
  override_foldtext = true,

  -- 'treesitter' lit queries/<ft>/folds.scm (@fold), 'indent' sert de filet
  provider_selector = function()
    return { "treesitter", "indent" }
  end,
}
