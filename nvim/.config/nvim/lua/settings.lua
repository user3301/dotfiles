vim.g.mapleader = " "

vim.cmd("set number")        -- show numbered lines
vim.cmd("set expandtab")     -- convert tabs to spaces
vim.cmd("set shiftwidth=2")  -- the number of spaces inserted for each indentation
vim.cmd("set tabstop=2")     -- insert 2 spaces for a tab
vim.cmd("set termguicolors") -- enable 24-bit RGB color in the terminal

vim.opt.showmode = false     -- don't show mode "INSERT", "NORMAL" in command
vim.opt.foldmethod = "manual"
