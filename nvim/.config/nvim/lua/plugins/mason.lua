-- Skip the Crashdummyy registry on NixOS — Mason-installed binaries break
-- there because they link against glibc paths absent from the Nix store.
-- On NixOS, Roslyn LS is provided by home-manager (`home/modules/neovim.nix`:
-- `roslyn-ls`), and roslyn.lua pins cmd to that binary.
local is_nixos = vim.fn.filereadable("/etc/NIXOS") == 1 or vim.fn.isdirectory("/etc/nixos") == 1

return {
  -- Extend Mason's registry list to include Crashdummyy/mason-registry,
  -- which ships roslyn-ls as a VSIX extract (works on systems where the
  -- nuget.org `roslyn-language-server` dotnet tool fails to install due to
  -- a missing DotnetToolSettings.xml). Install with `:MasonInstall roslyn`.
  "mason-org/mason.nvim",
  opts = {
    registries = is_nixos and {
      "github:mason-org/mason-registry",
    } or {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    },
  },
}
