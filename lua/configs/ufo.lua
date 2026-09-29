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
local function fold_virt_text_handler(virtual_text, start_lnum, end_lnum, width, truncate, ctx)
  local diagnostic_hl
  local diagnostics = vim.diagnostic.get(ctx.bufnr, {
    lnum = start_lnum - 1,
    end_lnum = end_lnum - 1,
  })

  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      diagnostic_hl = "DiagnosticLineError"
      break
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      diagnostic_hl = diagnostic_hl or "DiagnosticLineWarn"
    end
  end

  local suffix = (" 󰁅 %d lignes "):format(end_lnum - start_lnum + 1)
  local suffix_width = vim.fn.strdisplaywidth(suffix)
  local target_width = math.max(width - suffix_width, 0)
  local result = {}
  local current_width = 0
  local line = vim.api.nvim_buf_get_lines(ctx.bufnr, start_lnum - 1, start_lnum, false)[1] or ""

  -- `virtual_text` reçoit souvent le groupe Folded pour toute la ligne. On
  -- relit donc la première ligne du pli et demande à Treesitter la capture
  -- de chaque caractère afin de conserver les couleurs syntaxiques.
  local byte_col = 0
  while byte_col < #line and current_width < target_width do
    local char = vim.fn.strpart(line, byte_col, 1)
    local char_width = vim.fn.strdisplaywidth(char)
    if current_width + char_width > target_width then
      break
    end

    local hl = diagnostic_hl or "Normal"
    local captures
    if not diagnostic_hl and vim.treesitter.get_captures_at_pos then
      local ok, result = pcall(
        vim.treesitter.get_captures_at_pos,
        ctx.bufnr,
        start_lnum - 1,
        byte_col
      )
      if ok then
        captures = result
      end
    end
    if not diagnostic_hl and captures and #captures > 0 then
      local capture = captures[#captures][1]
      hl = capture:sub(1, 1) == "@" and capture or "@" .. capture
    end

    local last = result[#result]
    if last and last[2] == hl then
      last[1] = last[1] .. char
    else
      result[#result + 1] = { char, hl }
    end
    current_width = current_width + char_width
    byte_col = byte_col + #char
  end

  result[#result + 1] = { string.rep(" ", math.max(target_width - current_width, 0)), diagnostic_hl or "UfoFoldedEllipsis" }
  result[#result + 1] = { suffix, diagnostic_hl or "UfoFoldedEllipsis" }
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
