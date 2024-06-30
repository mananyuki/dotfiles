return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim",
    },
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.commitlint,
        nls.builtins.diagnostics.textlint,
        nls.builtins.formatting.biome,
        nls.builtins.formatting.buf,
        require("none-ls.formatting.rustfmt"),
        require("none-ls.formatting.trim_newlines"),
        require("none-ls.formatting.trim_whitespace"),
      })
    end,
  },
}
