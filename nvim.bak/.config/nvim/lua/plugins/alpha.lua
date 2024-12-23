return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'nvim-lua/plenary.nvim'
  },
  config = function ()
    local alpha = require'alpha'
    local dashboard = require'alpha.themes.dashboard'
    local daysoftheweek={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
    local day=daysoftheweek[os.date("*t").wday]
    if (day == "Monday") then
      dashboard.section.header.val = {
        [[███    ███  ██████  ███    ██ ██████   █████  ██    ██ ]],
        [[████  ████ ██    ██ ████   ██ ██   ██ ██   ██  ██  ██  ]],
        [[██ ████ ██ ██    ██ ██ ██  ██ ██   ██ ███████   ████   ]],
        [[██  ██  ██ ██    ██ ██  ██ ██ ██   ██ ██   ██    ██    ]],
        [[██      ██  ██████  ██   ████ ██████  ██   ██    ██    ]],
      }
    elseif (day == "Tuesday") then
      dashboard.section.header.val = {
        [[████████ ██    ██ ███████ ███████ ██████   █████  ██    ██ ]],
        [[   ██    ██    ██ ██      ██      ██   ██ ██   ██  ██  ██  ]],
        [[   ██    ██    ██ █████   ███████ ██   ██ ███████   ████   ]],
        [[   ██    ██    ██ ██           ██ ██   ██ ██   ██    ██    ]],
        [[   ██     ██████  ███████ ███████ ██████  ██   ██    ██    ]],
      }
    elseif (day == "Wednesday") then
      dashboard.section.header.val = {
        [[██     ██ ███████ ██████  ███    ██ ███████ ███████ ██████   █████  ██    ██ ]],
        [[██     ██ ██      ██   ██ ████   ██ ██      ██      ██   ██ ██   ██  ██  ██  ]],
        [[██  █  ██ █████   ██   ██ ██ ██  ██ █████   ███████ ██   ██ ███████   ████   ]],
        [[██ ███ ██ ██      ██   ██ ██  ██ ██ ██           ██ ██   ██ ██   ██    ██    ]],
        [[ ███ ███  ███████ ██████  ██   ████ ███████ ███████ ██████  ██   ██    ██    ]],
      }
    elseif (day == "Thursday") then
      dashboard.section.header.val  = {
        [[████████ ██   ██ ██    ██ ██████  ███████ ██████   █████  ██    ██ ]],
        [[   ██    ██   ██ ██    ██ ██   ██ ██      ██   ██ ██   ██  ██  ██  ]],
        [[   ██    ███████ ██    ██ ██████  ███████ ██   ██ ███████   ████   ]],
        [[   ██    ██   ██ ██    ██ ██   ██      ██ ██   ██ ██   ██    ██    ]],
        [[   ██    ██   ██  ██████  ██   ██ ███████ ██████  ██   ██    ██    ]],
      }
    elseif (day == "Friday") then
      dashboard.section.header.val = {
        [[███████ ██████  ██ ██████   █████  ██    ██ ]],
        [[██      ██   ██ ██ ██   ██ ██   ██  ██  ██  ]],
        [[█████   ██████  ██ ██   ██ ███████   ████   ]],
        [[██      ██   ██ ██ ██   ██ ██   ██    ██    ]],
        [[██      ██   ██ ██ ██████  ██   ██    ██    ]],
      }
    elseif (day == "Saturday") then
      dashboard.section.header.val = {
        [[███████  █████  ████████ ██    ██ ██████  ██████   █████  ██    ██ ]],
        [[██      ██   ██    ██    ██    ██ ██   ██ ██   ██ ██   ██  ██  ██  ]],
        [[███████ ███████    ██    ██    ██ ██████  ██   ██ ███████   ████   ]],
        [[     ██ ██   ██    ██    ██    ██ ██   ██ ██   ██ ██   ██    ██    ]],
        [[███████ ██   ██    ██     ██████  ██   ██ ██████  ██   ██    ██    ]],
      }
    else
      dashboard.section.header.val = {
        [[███████ ██    ██ ███    ██ ██████   █████  ██    ██ ]],
        [[██      ██    ██ ████   ██ ██   ██ ██   ██  ██  ██  ]],
        [[███████ ██    ██ ██ ██  ██ ██   ██ ███████   ████   ]],
        [[     ██ ██    ██ ██  ██ ██ ██   ██ ██   ██    ██    ]],
        [[███████  ██████  ██   ████ ██████  ██   ██    ██    ]],
      }
    end
    dashboard.section.buttons.val = {
      dashboard.button("e", " New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "󰈞 Find file", "<CMD>Telescope find_files<CR>"),
      dashboard.button("p", " Projects", "<CMD>Telescope projects<CR>"),
      dashboard.button("r", " Recent files", "<CMD>Telescope oldfiles<CR>"),
      dashboard.button("t", "󰊄 Find text", "<CMD>Telescope live_grep<CR>"),
      dashboard.button("q", "󰅖 Quit", "<CMD>quit<CR>"),
    }
    alpha.setup(dashboard.config)
    vim.keymap.set("n", ";", "<cmd>Alpha<CR>", {})
  end
}
