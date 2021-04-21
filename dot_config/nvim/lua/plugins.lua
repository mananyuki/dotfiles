vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  use {'wbthomason/packer.nvim', opt = true}

  use 'norcalli/nvim-base16.lua'
  use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'}
  use 'glepnir/galaxyline.nvim'
  use 'lewis6991/gitsigns.nvim'
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

  use 'kyazdani42/nvim-web-devicons'
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'

  use 'neovim/nvim-lspconfig'
  use 'onsails/lspkind-nvim'
  use 'windwp/nvim-autopairs'
  use 'hrsh7th/nvim-compe'
  use 'scalameta/nvim-metals'

  use 'tmux-plugins/vim-tmux-focus-events'
  use 'brglng/vim-im-select'
end)
