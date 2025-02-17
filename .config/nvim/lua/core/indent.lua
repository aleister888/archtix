-- Indentación y tabulación

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		local opt = vim.opt_local
		opt.smartindent = false
		opt.cindent = false
		opt.expandtab = false
		opt.copyindent = true
		opt.preserveindent = true
		opt.tabstop = 8
		opt.shiftwidth = 8
	end,
})

-- Java
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function()
		local opt = vim.opt_local
		opt.smartindent = false
		opt.cindent = false
		opt.expandtab = true
		opt.copyindent = true
		opt.preserveindent = true
		opt.tabstop = 4
		opt.shiftwidth = 4
	end,
})

-- CSS/SCSS
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*css",
	callback = function()
		local opt = vim.opt_local
		opt.smartindent = false
		opt.cindent = false
		opt.expandtab = true
		opt.copyindent = true
		opt.preserveindent = true
		opt.tabstop = 2
		opt.shiftwidth = 2
	end,
})

-- laTeX
vim.api.nvim_create_autocmd("FileType", {
	pattern = "tex",
	callback = function()
		local opt = vim.opt_local
		opt.smartindent = true
		opt.cindent = false
		opt.expandtab = false
		opt.copyindent = true
		opt.preserveindent = true
		opt.tabstop = 8
		opt.shiftwidth = 2
	end,
})
