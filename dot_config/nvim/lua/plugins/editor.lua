return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>"},
      { "<leader>ff", "<cmd>Telescope find_files<cr>" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>" },
      { "<leader>sg", "<cmd>Telescope live_grep<cr>" },
      { "<leader>sR", "<cmd>Telescope resume<cr>" },
    },
    opts = function()
      local vimgrep_arguments = { unpack(require("telescope.config").values.vimgrep_arguments) }
      table.insert(vimgrep_arguments, "--hidden")
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")

      return {
        defaults = {
          vimgrep_arguments = vimgrep_arguments
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          },
        },
      }
    end
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
  },
}
