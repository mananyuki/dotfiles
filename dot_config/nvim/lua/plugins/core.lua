return {
  "folke/lazy.nvim",

  {
    "nvim-mini/mini.basics",
    opts = {
      options = {
        extra_ui = true,
      },
      mappings = {
        windows = true,
        move_with_alt = true,
      },
      autocommands = {
        relnum_in_visual_mode = true,
      },
    },
    config = function(_, opts)
      require("mini.basics").setup(opts)
    end,
  },
}
