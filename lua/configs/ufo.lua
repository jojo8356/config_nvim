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

local cfg = {
  filler = "─", -- caractère de remplissage (largeur display = 1)
  left = "{ ", -- crochet ouvrant
  right = " }", -- crochet fermant
  show_content = true, -- false => uniquement { ─── 24 lines ─── }, sans la ligne dupliquée
  total_lines = true, -- true => lignes du pli, false => lignes masquées
  show_kind = true, -- ajoute le type de pli (noeud treesitter / kind LSP) quand il est connu
  filler_hl = "UfoFoldedEllipsis", -- ufo : `hi default link UfoFoldedEllipsis Comment`
  count_hl = "UfoFoldedEllipsis",
  kind_hl = "Special",
}

local function strwidth(text)
  return vim.fn.strdisplaywidth(text)
end

--- Rempile les chunks de `virtual_text` jusqu'à `max_width`, en tronquant celui qui déborde.
---@return table chunks { { text, hl_group }, ... }
---@return number used largeur display consommée
local function fit(virtual_text, max_width, truncate)
  local chunks, used = {}, 0

  for _, chunk in ipairs(virtual_text) do
    local text, hl = chunk[1], chunk[2] or "Normal"
    local chunk_width = strwidth(text)

    if used + chunk_width <= max_width then
      table.insert(chunks, { text, hl })
      used = used + chunk_width
    else
      local remain = max_width - used
      if remain > 0 then
        text = truncate(text, remain)
        table.insert(chunks, { text, hl })
        used = used + strwidth(text)
      end
      break -- plus de place : la fin de ligne appartient au compteur
    end
  end

  return chunks, used
end

--- Nom "lisible" du pli : function_declaration -> "function", import_statement -> "import"...
---@return string?
local function fold_kind(ctx, start_lnum)
  if not (ctx and type(ctx.get_fold_kind) == "function") then
    return nil
  end

  local ok, kind = pcall(ctx.get_fold_kind, start_lnum)
  if not ok or type(kind) ~= "string" or kind == "" then
    return nil
  end

  return (kind
    :gsub("_declaration$", "")
    :gsub("_statement$", "")
    :gsub("_block$", "")
    :gsub("_literal$", "")
    :gsub("_", " "))
end

--- Textes de remplissage : `count` unités de `cfg.filler` (compatible caractères doubles).
local function filler_text(count)
  local unit = math.max(1, strwidth(cfg.filler))
  return cfg.filler:rep(math.max(0, math.floor(count / unit)))
end

local function total_width(chunks)
  local width = 0
  for _, chunk in ipairs(chunks) do
    width = width + strwidth(chunk[1])
  end
  return width
end

local function fold_text_handler(virtual_text, start_lnum, end_lnum, width, truncate, ctx)
  -- garde-fou : fenêtre si étroite que le décor ne rentre pas -> ligne brute, sans crochet
  if width <= strwidth(cfg.left) + strwidth(cfg.right) then
    local chunk = virtual_text[1]
    local text = chunk and truncate(chunk[1], math.max(0, width)) or ""
    return { { text, chunk and chunk[2] or "Normal" } }
  end

  local line_count = math.max(0, end_lnum - start_lnum + (cfg.total_lines and 1 or 0))

  -- partie droite : " 24 lines" (+ "  function" si ufo connaît la kind du pli)
  local label_chunks = {
    { (" %d %s"):format(line_count, line_count == 1 and "line" or "lines"), cfg.count_hl },
  }
  local kind = cfg.show_kind and fold_kind(ctx, start_lnum) or nil
  if kind then
    table.insert(label_chunks, { ("  %s"):format(kind), cfg.kind_hl })
  end

  -- tout ce qui reste entre "{" et "}"
  local avail = math.max(0, width - strwidth(cfg.left) - strwidth(cfg.right))
  local label_width = total_width(label_chunks)

  if label_width > avail then
    -- fenêtre étroite : mieux vaut un compteur tronqué qu'une ligne qui déborde du pli
    label_chunks = fit(label_chunks, avail, truncate)
    label_width = total_width(label_chunks)
  end

  local inner = math.max(0, avail - label_width)

  local result = { { cfg.left, cfg.filler_hl } }
  local used = 0

  if cfg.show_content then
    local content
    content, used = fit(virtual_text, inner, truncate)
    for _, chunk in ipairs(content) do
      table.insert(result, chunk)
    end
  end

  -- les tirets restants entourent le compteur : ─── 24 lines ───
  local filler = math.max(0, inner - used)
  local left_pad = math.floor(filler / 2)
  local right_pad = filler - left_pad

  if left_pad > 0 then
    table.insert(result, { filler_text(left_pad), cfg.filler_hl })
  end
  for _, chunk in ipairs(label_chunks) do
    table.insert(result, chunk)
  end
  if right_pad > 0 then
    table.insert(result, { filler_text(right_pad), cfg.filler_hl })
  end
  table.insert(result, { cfg.right, cfg.filler_hl })

  -- ufo ne remplit pas la fin de ligne : sans ce padding, le fond du pli s'arrête au dernier
  -- chunk (et `truncate()` rend parfois moins large que demandé, d'où le recalcul).
  local tail = math.max(0, width - total_width(result))
  if tail > 0 then
    local last = result[#result]
    last[1] = last[1] .. (" "):rep(tail)
  end

  return result
end

return {
  -- indispensable pour que ce soit NOTRE handler qui dessine la ligne de pli
  override_foldtext = true,

  -- 'treesitter' lit queries/<ft>/folds.scm (@fold), 'indent' sert de filet
  provider_selector = function()
    return { "treesitter", "indent" }
  end,

  fold_virt_text_handler = fold_text_handler,
}
