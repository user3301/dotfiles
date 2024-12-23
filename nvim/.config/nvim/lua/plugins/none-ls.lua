return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        -- requires to install goimports to GOPATH,
        -- if go is installed via asdf, "asdf reshim golang" is required after installing goimports
        null_ls.builtins.formatting.goimports,
      },

      -- format on save, https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                async = false
              })
            end,
          })
        end
      end,
    })
  end
}
