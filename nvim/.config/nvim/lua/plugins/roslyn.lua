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
    -- Neovim defaults didChangeWatchedFiles.dynamicRegistration to false, so
    -- roslyn thinks the client won't watch files and falls back to its
    -- in-process .NET watcher (which stack-overflows -> SIGABRT). Turn it on
    -- so Neovim does the watching (via the fswatch backend on NixOS, or a
    -- system fswatch on other distros).
    local config = {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    }

    -- On NixOS, home-manager puts `Microsoft.CodeAnalysis.LanguageServer` on
    -- PATH via the roslyn-ls nixpkg. Pin cmd to it. On other distros (Arch,
    -- etc.), leave cmd unset so roslyn.nvim auto-discovers the Mason install
    -- (`:MasonInstall roslyn` from Crashdummyy/mason-registry).
    local exe = vim.fn.exepath("Microsoft.CodeAnalysis.LanguageServer")
    if exe ~= "" then
      config.cmd = {
        exe,
        "--logLevel",
        "Information",
        "--extensionLogDirectory",
        vim.fs.joinpath(vim.fn.stdpath("log"), "roslyn_ls"),
        "--stdio",
      }
    end

    vim.lsp.config("roslyn", config)
  end,
}
