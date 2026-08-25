local health = vim.health

local M = {}

local function uniq(values)
  local seen = {}
  local out = {}

  for _, value in ipairs(values) do
    if value ~= nil and not seen[value] then
      seen[value] = true
      out[#out + 1] = value
    end
  end

  return out
end

local function check_ts_language(language)
  local ok, parser = pcall(vim.treesitter.get_parser, nil, language)
  if not ok or not parser then
    health.warn(string.format("%s parser not found", language))
  else
    health.ok(string.format("%s parser found", language))
  end
end

function M.check()
  local config = require("ts-autotag.config").config

  health.start("TS parsers:")

  local languages = {}
  for _, filetype in ipairs(config.filetypes) do
    languages[#languages + 1] = vim.treesitter.language.get_lang(filetype)
  end

  for i, lang in ipairs(languages) do
    if not lang then
      health.error(string.format("%s filetype does not have associated ts language", config.filetypes[i]))
    end
  end

  for _, lang in ipairs(uniq(languages)) do
    check_ts_language(lang)
  end
end

return M
