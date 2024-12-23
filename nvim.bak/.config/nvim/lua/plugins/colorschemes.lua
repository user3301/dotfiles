return {
  {
    'morhetz/gruvbox',
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end
  },
  vim.keymap.set("n", "<leader>sp", ":lua require('telescope.builtin').colorscheme({enable_preview = true})<CR>",
    { noremap = true, silent = true })
}
