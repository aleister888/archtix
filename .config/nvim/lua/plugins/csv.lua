return {
	"hat0uma/csvview.nvim",
	opts = {
		parser = { comments = { "#", "//" } },
		ft = { "csv" },
		keymaps = {
			-- Text objects for selecting fields
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
		},
	},
	vim.keymap.set("n", "<leader>f", function()
		vim.cmd("CsvViewToggle")
	end, { silent = true }),
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
}
