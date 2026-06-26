return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Disable csharpier for C#; fall back to omnisharp's LSP formatting
    -- (lsp_format = "fallback"), which honors .editorconfig.
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.cs = {}
  end,
}
