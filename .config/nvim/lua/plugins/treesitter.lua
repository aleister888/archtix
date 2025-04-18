return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	build = ":TSUpdate",
	opts = {
		highlight = {
			enable = true,
			disable = { "csv" },
		},
		indent = { enable = true },
		auto_install = true,
		ensure_installed = {
			"json",
			"lua",
			"c",
			"bash",
			"latex",
			"java",
			"markdown",
			"yuck",
			"xml",
			"css",
			"scss",
			"zathurarc",
			"ruby",
			"diff",
			"gitcommit",
		},
	},
	config = function(_, opts)
		local configs = require("nvim-treesitter.configs")
		configs.setup(opts)
	end,
}
