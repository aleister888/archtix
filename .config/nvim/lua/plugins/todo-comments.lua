return {
	"folke/todo-comments.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	config = true,
	init = function()
		require("todo-comments").setup({
			keywords = {
				TODO = { icon = "󱒔 ", color = "info" },
				FIXME = { icon = " ", color = "warning" },
			},
			highlight = {
				-- Resalta comentarios a través de varias lineas
				multiline = true,
				-- Patrón para detectar palabras clave
				pattern = [[(KEYWORDS)\s*]],
				keyword = "fg",
				-- Mostrar solo en los comentarios
				comments_only = true,
			},
		})
		vim.keymap.set("n", "]t", function()
			require("todo-comments").jump_next()
		end, { desc = "Siguiente TODO" })

		vim.keymap.set("n", "[t", function()
			require("todo-comments").jump_prev()
		end, { desc = "Anterior TODO" })
	end,
}
