-- current colorscheme
lvim.colorscheme = "gruvbox"
lvim.transparent_window = true

-- custom plugins 
lvim.plugins = {
  {'morhetz/gruvbox'},
  {'fatih/vim-go'},
  {"junegunn/fzf"},
  {"junegunn/fzf.vim"},
  {"github/copilot.vim",
    event = {"BufReadPost", "BufNewFile"}
  }
}
