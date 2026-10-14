return {
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {},
    init = function()
      -- Use Neovim's file watcher instead of the .NET watcher that previously crashed.
      local config = {
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
      }

      -- Nix packages the server, not the thin client that accepts --daemon-mode.
      local exe = vim.fn.exepath("Microsoft.CodeAnalysis.LanguageServer")
      if exe ~= "" then
        config.cmd = { exe, "--stdio" }
      end

      vim.lsp.config("roslyn", config)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp" } },
  },
}
