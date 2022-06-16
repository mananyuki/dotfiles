require'plugins'

vim.cmd 'set autowrite'
vim.cmd 'set clipboard^=unnamedplus'
vim.cmd 'set expandtab shiftwidth=2'
vim.cmd 'set hidden'
vim.cmd 'set ignorecase'
vim.cmd 'set linebreak'
vim.cmd 'set nobackup'
vim.cmd 'set noshowmode'
vim.cmd 'set noswapfile'
vim.cmd 'set nowritebackup'
vim.cmd 'set number relativenumber'
vim.cmd 'set shortmess+=c'
vim.cmd 'set showbreak=+++'
vim.cmd 'set showmatch'
vim.cmd 'set signcolumn=yes'
vim.cmd 'set smartcase'
vim.cmd 'set smartindent'
vim.cmd 'set softtabstop=2'
vim.cmd 'set textwidth=120'
vim.cmd 'set undolevels=1000'
vim.cmd 'set updatetime=300'
vim.cmd 'set visualbell'
vim.cmd 'set spelllang=en,cjk'

vim.g.mapleader = " "
vim.g.python3_host_prog = '~/.asdf/shims/python3'

local opt = {noremap = true, silent = true}
vim.api.nvim_set_keymap("n", "<Leader>w", [[<Cmd>w<CR>]], opt)
vim.api.nvim_set_keymap("n", "<M-h>", "<C-w>h", opt)
vim.api.nvim_set_keymap("n", "<M-j>", "<C-w>j", opt)
vim.api.nvim_set_keymap("n", "<M-k>", "<C-w>k", opt)
vim.api.nvim_set_keymap("n", "<M-l>", "<C-w>l", opt)
vim.api.nvim_set_keymap("i", "<M-h>", "<C-w>h", opt)
vim.api.nvim_set_keymap("i", "<M-j>", "<C-w>j", opt)
vim.api.nvim_set_keymap("i", "<M-k>", "<C-w>k", opt)
vim.api.nvim_set_keymap("i", "<M-l>", "<C-w>l", opt)
vim.api.nvim_set_keymap("t", "<M-h>", [[<C-\><C-n><C-w>h]], opt)
vim.api.nvim_set_keymap("t", "<M-j>", [[<C-\><C-n><C-w>j]], opt)
vim.api.nvim_set_keymap("t", "<M-k>", [[<C-\><C-n><C-w>k]], opt)
vim.api.nvim_set_keymap("t", "<M-l>", [[<C-\><C-n><C-w>l]], opt)

vim.cmd 'syntax enable'
vim.cmd 'syntax on'
vim.cmd 'set termguicolors'

local base16 = require"base16"
base16(base16.themes.nord, true)

require'nvim-web-devicons'.setup {
  default = true
}

require'statusline'

require'language-servers'
require'completion'

require'finder'

require'gitsigns'.setup()
require'nvim-autopairs'.setup()
require'which-key'.setup()
require'lspkind'.init()

require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "go",
    "hcl",
    "javascript",
    "lua",
    "python",
    "rust",
    "scala",
    "tsx",
    "typescript",
    "yaml",
  },
  sync_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- vim.g.indent_blankline_space_char = '·'
vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_show_end_of_line = true
