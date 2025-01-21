return {
  "yamatsum/nvim-nonicons",
  requires = { "kyazdani42/nvim-web-devicons" },
  config = function ()
    require("nvim-nonicons").setup()
  end
}
