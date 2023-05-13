return {
  {
    "echasnovski/mini.statusline",
    opts = {
      set_vim_settings = false,
    },
    config = function(_, opts)
      require("mini.statusline").setup(opts)
    end,
  },

  {
    "echasnovski/mini.indentscope",
    event = { "BufReadPost", "BufNewFile" },
    config = function(_, opts)
      require("mini.indentscope").setup(opts)
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },
}
