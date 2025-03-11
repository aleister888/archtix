return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>a",
			function()
				require("conform").format({ async = false })
			end,
			mode = "",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			java = { "astyle" },
			sh = { "shfmt" },
			tex = { "latexindent" },
			markdown = { "prettier" },
			scss = { "prettier" },
			css = { "prettier" },
			xml = { "xmllint" },
		},
		format_on_save = { timeout_ms = 5000 },
		formatters = {
			astyle = {
				prepend_args = { "--style=allman", "--indent=tab=8", "-n" },
			},
			latexindent = {
				prepend_args = {
					"--curft=/tmp",
					"-",
				},
			},
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
