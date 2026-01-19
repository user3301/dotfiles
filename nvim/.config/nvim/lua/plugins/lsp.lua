-- Detect if running on NixOS
local is_nixos = vim.fn.filereadable("/etc/NIXOS") == 1 or vim.fn.isdirectory("/etc/nixos") == 1

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Use Nix-installed LSP servers on NixOS, Mason on other systems
        lua_ls = {
          mason = not is_nixos,
        },
        nil_ls = {
          mason = not is_nixos,
        },
        ts_ls = {
          mason = not is_nixos,
        },
        html = {
          mason = not is_nixos,
        },
        cssls = {
          mason = not is_nixos,
        },
        jsonls = {
          mason = not is_nixos,
        },
        eslint = {
          mason = not is_nixos,
        },
        pyright = {
          mason = not is_nixos,
        },
        rust_analyzer = {
          mason = not is_nixos,
        },
        gopls = {
          mason = not is_nixos,
          -- Explicitly use Nix-installed gopls on NixOS to ensure we don't pick up
          -- any other version (e.g., from Mason cache, system package, or Go install)
          cmd = is_nixos and { vim.fn.exepath("gopls") } or nil,
          -- when Neovim starts gopls as an LSP server, it may not be inheriting
          -- the correct environment variables that NixOS sets up.
          cmd_env = {
            GOPATH = vim.env.GOPATH or vim.fn.expand("$HOME/go"),
            GOROOT = vim.env.GOROOT,
            GOMODCACHE = vim.env.GOMODCACHE or vim.fn.expand("$HOME/go/pkg/mod"),
          },
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
        pylsp = {
          -- Dynamically find pylsp in virtualenv
          on_new_config = function(config, root_dir)
            local venv_paths = { "venv", ".venv", ".virtualenv" }
            for _, venv in ipairs(venv_paths) do
              local venv_pylsp = root_dir .. "/" .. venv .. "/bin/pylsp"
              if vim.fn.executable(venv_pylsp) == 1 then
                config.cmd = { venv_pylsp }
                break
              end
            end
          end,
          on_attach = function(_, bufnr)
            -- Auto-import missing imports and format on save
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                local root_dir = vim.fn.getcwd()
                local venv_paths = { "venv", ".venv", ".virtualenv" }
                local autoimport_cmd = nil

                -- Find autoimport in virtualenv
                for _, venv in ipairs(venv_paths) do
                  local venv_autoimport = root_dir .. "/" .. venv .. "/bin/autoimport"
                  if vim.fn.executable(venv_autoimport) == 1 then
                    autoimport_cmd = venv_autoimport
                    break
                  end
                end

                -- Run autoimport if available
                if autoimport_cmd then
                  local filename = vim.api.nvim_buf_get_name(bufnr)
                  vim.fn.system(autoimport_cmd .. " " .. vim.fn.shellescape(filename))
                  -- Reload the buffer to see changes
                  vim.cmd("edit!")
                end

                -- Then format with ruff
                vim.lsp.buf.format({ async = false })
              end,
            })
          end,
          settings = {
            pylsp = {
              plugins = {
                -- Enable ruff for formatting and organizing imports
                ruff = {
                  enabled = true,
                  formatEnabled = true,
                  lineLength = 88,
                  select = { "F", "I" }, -- F = Pyflakes, I = isort/import sorting
                  fixAll = true,
                },
                -- Disable conflicting plugins
                pycodestyle = { enabled = false },
                mccabe = { enabled = false },
                pyflakes = { enabled = false },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                isort = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
}
