require("nvchad.configs.lspconfig").defaults()

vim.schedule(function()
  local lspconfig = vim.lsp.config

  -- ⚙️ HTML
  local html_cfg = vim.tbl_deep_extend("force", lspconfig.html, {
    cmd = { "html-languageserver", "--stdio" },
  })
  vim.lsp.start(html_cfg)

  -- ⚙️ CSS
  local css_cfg = vim.tbl_deep_extend("force", lspconfig.cssls, {
    cmd = { "css-languageserver", "--stdio" },  -- 👈 ici on change la commande
  })
  vim.lsp.start(css_cfg)

  local tw_cfg = vim.tbl_deep_extend("force", lspconfig.tailwindcss or {}, {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = { "html", "css", "javascriptreact", "typescriptreact", "vue", "svelte" },
    root_dir = vim.fs.dirname(vim.fs.find({ "tailwind.config.js", ".git" }, { upward = true })[1]),
  })
  vim.lsp.start(tw_cfg)

  -- ⚙️ Dart
  local dart_cfg = lspconfig.dartls
  if dart_cfg then
    vim.lsp.start(dart_cfg)
  end
end)

vim.api.nvim_create_autocmd({ "FileType" }, {
	  pattern = "css,eruby,html,htmldjango,javascriptreact,less,pug,sass,scss,typescriptreact",
	  callback = function()
	    vim.lsp.start({
	      cmd = { "emmet-language-server", "--stdio" },
	      root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
	      init_options = {
		-- Emmet configuration options go here
	      },
	    })
	  end,
	})

require('substitute').setup()
require("cmp").config.formatting = {
  format = require("tailwindcss-colorizer-cmp").formatter
}

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    require("conform").format()
  end,
})
