vim.g.mapleader = " "
vim.g.python3_host_prog = "~/.asdf/shims/python3"

vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.expandtab = true
vim.opt.laststatus = 3
vim.opt.listchars = "extends:…,precedes:…,tab:»-,nbsp:␣"
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.spelllang = "en,cjk"

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"go.sum", "go.work.sum"},
  callback = function() vim.opt.filetype = "gosum" end
})
vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = {"go"},
  callback = function()
    vim.opt.expandtab = false
    vim.opt.shiftwidth = 0
  end
})

require("config.lazy")
