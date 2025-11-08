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
          on_attach = function(client, bufnr)
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
                -- Enable rope for refactoring and auto-imports
                rope_autoimport = {
                  enabled = true,
                  memory = true,
                },
                rope_completion = {
                  enabled = true,
                  eager = true,
                },
                -- Jedi settings
                jedi_completion = {
                  enabled = true,
                  include_params = true,
                  fuzzy = true,
                },
                jedi_hover = { enabled = true },
                jedi_references = { enabled = true },
                jedi_signature_help = { enabled = true },
                jedi_symbols = { enabled = true },
                -- Enable ruff for auto-imports and linting
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
