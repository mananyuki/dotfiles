return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          automatic_installation = true,
        },
      },
      "hrsh7th/cmp-nvim-lsp",
    },
    keys = {
      { "<space>e", vim.diagnostic.open_float, desc = "Line Diagnostics" },
      { "[d", vim.diagnostic.goto_prev, desc = "Prev Diagnostic" },
      { "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
      { "<space>q", vim.diagnostic.setloclist, desc = "Add Diagnostics to the location list" },
      { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definition" },
      { "K", vim.lsp.buf.hover, desc = "Hover" },
      { "gi", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
      { "<C-k>", vim.lsp.buf.signature_help, desc = "Signature Help" },
      { "<leader>wa", vim.lsp.buf.add_workspace_folder },
      { "<leader>wr", vim.lsp.buf.remove_workspace_folder },
      { "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end },
      { "gy", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Goto Type Definition" },
      { "<leader>rn", vim.lsp.buf.rename, desc = "Rename" },
      { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" }, desc = "Code Action" },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format" },
    },
    config = function(_, opts)
      local nvim_lsp = require("lspconfig")

      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Use a loop to conveniently call 'setup' on multiple servers and
      -- map buffer local keybindings when the language server attaches
      local servers = {
        "bashls",
        "bufls",
        "denols",
        "dockerls",
        "gopls",
        "grammarly",
        "jsonls",
        "lua_ls",
        "metals",
        "pyright",
        "rome",
        "rust_analyzer",
        "terraformls",
        "yamlls",
      }
      for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup({ capabilities = capabilities })
      end
    end,
  },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.gofmt,
        },
      }
    end,
  },

  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    opts = {
      ensure_installed = {
        "stylua",
        "rustfmt",
      },
      automatic_installation = true,
      automatic_setup = true,
    },
  },
}
