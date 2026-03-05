return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        dockerfile = { "hadolint" },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.yamlls.settings.yaml.format.enable = false
    end,
  },
}
