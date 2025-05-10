-- Instalar lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Definimos la tecla leader antes de iniciar lazy
vim.g.mapleader = ","
vim.g.maplocalleader = "."

require("core.options")
require("core.indent")
require("core.keymaps")
require("core.spell")

require("lazy").setup("plugins", {
	change_detection = {
		enabled = true,
		notify = false,
	},
})
