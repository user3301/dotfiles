return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              -- 👇 This makes gopls group imports as stdlib / third-party / local
              formatting = {
                ["local"] = "github.com/anzx/fabric-entitlements",
              },
              gofumpt = true, -- optional: stricter formatting
            },
          },
        },
      },
    },
  },
}
