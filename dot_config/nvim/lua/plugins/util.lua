return {
  {
    "echasnovski/mini.starter",
    config = function(_, opts)
      require("mini.starter").setup(opts)
    end,
  },

  { "nvim-lua/popup.nvim", lazy = true },

  { "nvim-lua/plenary.nvim", lazy = true },

  { "tmux-plugins/vim-tmux-focus-events", lazy = true },
}
