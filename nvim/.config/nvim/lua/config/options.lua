-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opts = vim.opt

opts.relativenumber = false
opts.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opts.foldmethod = "expr"
