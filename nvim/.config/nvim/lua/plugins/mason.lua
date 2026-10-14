-- Nix provides Roslyn on NixOS; keep the extra Mason registry for other systems.
local is_nixos = vim.fn.filereadable("/etc/NIXOS") == 1 or vim.fn.isdirectory("/etc/nixos") == 1

return {
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
