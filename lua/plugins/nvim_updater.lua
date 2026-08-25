return {
  {
    "rootiest/nvim-updater.nvim",
    version = "*",
    opts = {
      source_dir = vim.fn.expand "~/.local/src/neovim",
      build_type = "Release",
      branch = "release-0.10",
      check_for_updates = false,
      notify_updates = true,
      default_keymaps = false,
    },
    keys = {
      {
        "<leader>nuu",
        function()
          require("nvim_updater").update_neovim()
        end,
        desc = "Neovim: update source build",
      },
      {
        "<leader>nud",
        function()
          require("nvim_updater").update_neovim { build_type = "Debug" }
        end,
        desc = "Neovim: update debug build",
      },
      {
        "<leader>nur",
        ":NVUpdateRemoveSource<CR>",
        desc = "Neovim: remove source tree",
      },
    },
  },
}
