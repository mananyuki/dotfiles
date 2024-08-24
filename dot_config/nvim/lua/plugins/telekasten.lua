return {
  {
    "nvim-telekasten/telekasten.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-media-files.nvim",
      "nvim-telekasten/calendar-vim",
    },
    keys = function()
      return {
        { "<leader>z", "<cmd>Telekasten panel<cr>", mode = { "n" }, desc = "Launch Telekasten Panel" },
        { "<leader>zf", "<cmd>Telekasten find_notes<CR>", mode = { "n" }, desc = "Find notes by title (filename)" },
        { "<leader>zg", "<cmd>Telekasten search_notes<CR>", mode = { "n" }, desc = "Search (grep) in all notes" },
        { "<leader>zd", "<cmd>Telekasten goto_today<CR>", mode = { "n" }, desc = "Open today's daily note" },
        { "<leader>zz", "<cmd>Telekasten follow_link<CR>", mode = { "n" }, desc = "Follow the link under the cursor" },
        { "<leader>zn", "<cmd>Telekasten new_note<CR>", mode = { "n" }, desc = "Create a new note, prompts for title" },
        { "<leader>zc", "<cmd>Telekasten show_calendar<CR>", mode = { "n" }, desc = "Show the calendar" },
        {
          "<leader>zb",
          "<cmd>Telekasten show_backlinks<CR>",
          mode = { "n" },
          desc = "Show all notes linking to the current one",
        },
        {
          "<leader>zI",
          "<cmd>Telekasten insert_img_link<CR>",
          mode = { "n" },
          desc = "Browse images / media files and insert a link to the selected one",
        },
        { "[[", "<cmd>Telekasten insert_link<CR>", mode = { "i" }, desc = "Insert a link to a note" },
      }
    end,
    opts = {
      home = vim.fn.expand("~/src/github.com/mananyuki/til"),
      dailies = vim.fn.expand("~/src/github.com/mananyuki/til/diaries"),
      weeklies = vim.fn.expand("~/src/github.com/mananyuki/til/diaries"),
      templates = vim.fn.expand("~/src/github.com/mananyuki/til/templates"),
    },
  },
}
