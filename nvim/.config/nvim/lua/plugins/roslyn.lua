return {
  -- Roslyn LSP for C# (replaces omnisharp; surfaces IDExxxx code-style
  -- diagnostics like Rider/VS). omnisharp is disabled in lsp.lua.
  "seblyng/roslyn.nvim",
  ft = "cs",
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    -- Let Neovim handle file watching via LSP (needs an fswatch backend,
    -- provided in neovim.nix). This keeps roslyn from falling back to its
    -- in-process .NET FileSystemWatcher, which recurses over the whole
    -- solution tree and stack-overflows (SIGABRT). With a real backend present,
    -- "auto" gives proper watching so out-of-editor changes are picked up.
    filewatching = "auto",
  },
  init = function()
    -- Point roslyn.nvim at the Nix-provided roslyn-ls binary (on PATH as
    -- `Microsoft.CodeAnalysis.LanguageServer`) instead of a Mason install.
    vim.lsp.config("roslyn", {
      cmd = {
        vim.fn.exepath("Microsoft.CodeAnalysis.LanguageServer"),
        "--logLevel",
        "Information",
        "--extensionLogDirectory",
        vim.fs.joinpath(vim.fn.stdpath("log"), "roslyn_ls"),
        "--stdio",
      },
      -- Neovim defaults didChangeWatchedFiles.dynamicRegistration to false, so
      -- roslyn thinks the client won't watch files and falls back to its
      -- in-process .NET watcher (which stack-overflows -> SIGABRT). Turn it on
      -- so Neovim does the watching (via the fswatch backend in neovim.nix).
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    })
  end,
}
