vim.g.mapleader = " "
vim.g.python3_host_prog = "~/.asdf/shims/python3"

vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.expandtab = true
vim.opt.laststatus = 3
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.spelllang = "en,cjk"

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"go.sum", "go.work.sum"},
  callback = function() vim.opt.filetype = "gosum" end
})

require("config.lazy")
