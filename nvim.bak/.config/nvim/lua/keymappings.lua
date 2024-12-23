local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("n", "<leader>c", ":bd<CR>", opts)
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":wa <bar> <esc>:qa<CR>", opts)
keymap("n", "<leader>h", "<cmd>noh<CR>", opts)

-- better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- better window resizing
if vim.fn.has "mac" == 1 then
  keymap("n", "<A-Up>", ":resize -2<CR>", opts)
  keymap("n", "<A-Down>", ":resize +2<CR>", opts)
  keymap("n", "<A-Left>", ":vertical resize -2<CR>", opts)
  keymap("n", "<A-Right>", ":vertical resize +2<CR>", opts)
else
  keymap("n", "<C-Up>", ":resize -2<CR>", opts)
  keymap("n", "<C-Down>", ":resize +2<CR>", opts)
  keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
  keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "help",
    "lspinfo",
    "man",
    "checkhealth",
  },
  command = [[
  nnoremap <buffer><silent> q :close<CR>
  set nobuflisted
  ]],
})
