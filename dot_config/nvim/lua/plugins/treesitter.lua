return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bash",
        "go",
        "gomod",
        "gosum",
        "hcl",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "python",
        "rust",
        "scala",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
  },
}
