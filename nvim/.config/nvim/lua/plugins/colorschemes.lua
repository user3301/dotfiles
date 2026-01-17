return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  { "neanias/everforest-nvim" },
  { "sainnhe/gruvbox-material" },
  { "rose-pine/neovim", name = "rose-pine" },
  -- Configure LazyVim to load selected colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
  -- TODO: currently this config will preventing light themes from
  -- displaying properly as in WezTerm configuration there is a
  -- dark gradient background setting
  -- Make background transparent to inherit terminal settings
  -- {
  --   "LazyVim/LazyVim",
  --   opts = function()
  --     vim.api.nvim_create_autocmd("ColorScheme", {
  --       pattern = "*",
  --       callback = function()
  --         vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  --         vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  --         vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  --       end,
  --     })
  --   end,
  -- },
}
