-- stylua: ignore
function SetColorscheme()
	vim.cmd.colorscheme("gruvbox")
	-- Cambiar el color de los números de línea
	vim.api.nvim_set_hl(0, "LineNr",       { bg = nil,       fg = "#a89984" })
	vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "#282828", fg = "#fabd2f", bold = true })
	vim.api.nvim_set_hl(0, "NormalFloat",  { bg = "#282828", fg = "#a89984" })
	vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#282828" })
	-- https://github.com/nanozuki/tabby.nvim
	vim.api.nvim_set_hl(0, "TabLineFill",  { bg = "#282828", fg = "#a89984" })
	vim.api.nvim_set_hl(0, "TabLine",      { bg = "#282828", fg = "#a89984" })
	vim.api.nvim_set_hl(0, "TabLineSel",   { bg = "#282828", fg = "#a89984" })
	-- https://github.com/hrsh7th/nvim-cmp
	vim.api.nvim_set_hl(0, "PmenuSel",              { bg = "#282828", fg = "#a89984" })
	vim.api.nvim_set_hl(0, "Pmenu",                 { bg = "#3c3836", fg = "#ebdbb2" })
	vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { strikethrough = true })
end

return {
	"ellisonleao/gruvbox.nvim",
	priority = 1000,
	config = function()
		require("gruvbox").setup({
			transparent_mode = true,
			inverse = true,
			contrast = "hard",
		})
		SetColorscheme()
	end,
}
