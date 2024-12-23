return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    require("neo-tree").setup {
      source_selector = {
        statusline = true,
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        buffers = {
          follow_current_file = {
            enabled = true,
          }
        },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          never_show = {
            ".DS_Store",
            "thumbs.db",
          }
        }
      }
    }
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", opts)
    vim.keymap.set("n", "<leader>b", ":Neotree action=focus source=buffers position=float<CR>", opts)
  end
}
