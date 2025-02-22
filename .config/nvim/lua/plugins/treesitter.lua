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
		},
		indent = { enable = true },
		auto_install = true,
		ensure_installed = {
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
		},
	},
	config = function(_, opts)
		local configs = require("nvim-treesitter.configs")
		configs.setup(opts)
	end,
}
