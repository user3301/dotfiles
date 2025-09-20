return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true, -- show hidden files
        },
        explorer = {
          ignored = true, -- show gitignored files
          hidden = true, -- show hidden files
        },
      },
    },
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
 ██████╗  ██████╗ ██╗      █████╗ ███╗   ██╗██████╗ 
██╔════╝ ██╔═══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
██║  ███╗██║   ██║██║     ███████║██╔██╗ ██║██║  ██║
██║   ██║██║   ██║██║     ██╔══██║██║╚██╗██║██║  ██║
╚██████╔╝╚██████╔╝███████╗██║  ██║██║ ╚████║██████╔╝
 ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ 
]],
      },
    },
  },
}
