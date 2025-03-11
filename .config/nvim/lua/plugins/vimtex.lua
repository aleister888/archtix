return {
	"lervag/vimtex",
	-- Queremos que el plugin este cargado siempre para poder usar
	-- VimtexInverseSearch sin abrir ningún buffer, de forma que nuestro lector
	-- de PDF pueda hacer "reverse search" con synctex
	config = function()
		-- Configuración de VimTeX
		vim.g.vimtex_toc_config = { show_help = 0 }
		vim.g.vimtex_mappings_enabled = 0
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_compiler_method = "arara"
		vim.g.vimtex_quickfix_mode = 0
		vim.g.vimtex_syntax_enabled = 0

		-- Cargar los atajos solo para el tipo de archivo 'tex'
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "tex",
			callback = function()
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
				-- Alternar el índice de contenidos
				vim.keymap.set("n", "<leader>f", "<plug>(vimtex-toc-toggle)", { silent = true })
				-- Ver el documento
				vim.keymap.set("n", "<leader>h", ":VimtexView<CR>", { silent = true })
				-- Guardar y compilar con Vimtex
				vim.keymap.set("n", "<leader>g", ":w<CR>:VimtexCompile<CR>", { silent = true, buffer = true })
				-- Guardar y compilar manualmente con xelatex
				vim.keymap.set("n", "<leader>G", ":w<CR>:!xelatex %<CR>", { silent = true, buffer = true })
				-- Poner texto entre comillas
				vim.keymap.set("v", "`", "s`<C-r>\"'", { noremap = true, silent = true })
				vim.keymap.set("v", "<leader>`", "s``<C-r>\"''", { noremap = true, silent = true })
				-- Modos de texto
				vim.keymap.set("v", "<leader>e", 's\\emph{<C-r>"}', { silent = true })
				vim.keymap.set("v", "<leader>b", 's\\textbf{<C-r>"}', { silent = true })
				vim.keymap.set("v", "<leader>i", 's\\textit{<C-r>"}', { silent = true })
				vim.keymap.set("v", "<leader>t", 's\\text{<C-r>"}', { silent = true })
				vim.keymap.set("v", "<leader>m", 's\\texttt{<C-r>"}', { silent = true })
				vim.keymap.set("v", "<leader>h", 's\\hl{<C-r>"}', { silent = true })
			end,
		})
	end,
}
