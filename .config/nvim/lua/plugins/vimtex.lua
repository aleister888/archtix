return {
	"lervag/vimtex",
	config = function()
		-- Configuración de VimTeX
		vim.g.vimtex_toc_config = { show_help = 0 }
		vim.g.vimtex_mappings_enabled = 0
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_compiler_method = "arara"
		vim.g.vimtex_quickfix_mode = 0
		vim.g.vimtex_syntax_enabled = 0

		-- Mostrar errores
		vim.keymap.set("n", "<leader>j", function()
			local quickfix_exists = #vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix") > 0
			if quickfix_exists then
				vim.cmd("cclose")
			else
				vim.cmd("VimtexErrors")
			end
		end, { silent = true })
		vim.keymap.set("n", "<leader>k", "<plug>(vimtex-clean)", { silent = true })

		-- Definir autocmd para el tipo de archivo 'tex'
		vim.keymap.set("n", "<leader>f", "<plug>(vimtex-toc-toggle)", { silent = true })
		vim.keymap.set("n", "<leader>g", ":VimtexCompile<CR>", { silent = true })
		vim.keymap.set("n", "<leader>G", ":!xelatex %<CR>", { silent = true })
		vim.keymap.set("n", "<leader>h", ":VimtexView<CR>", { silent = true })

		-- Poner texto entre comillas
		vim.keymap.set("v", "`", "s`<C-r>\"'", { noremap = true, silent = true })
		vim.keymap.set("v", "<leader>`", "s``<C-r>\"''", { noremap = true, silent = true })

		-- Mapear las teclas para comandos de texto en modo visual
		vim.keymap.set("v", "e", 's\\emph{<C-r>"}', { silent = true })
		vim.keymap.set("v", "b", 's\\textbf{<C-r>"}', { silent = true })
		vim.keymap.set("v", "i", 's\\textit{<C-r>"}', { silent = true })
		vim.keymap.set("v", "t", 's\\text{<C-r>"}', { silent = true })
		vim.keymap.set("v", "m", 's\\texttt{<C-r>"}', { silent = true })
		vim.keymap.set("v", "h", 's\\hl{<C-r>"}', { silent = true })
	end,
}
