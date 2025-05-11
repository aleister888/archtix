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
			"bash",
			"c",
			"cpp",
			"css",
			"csv",
			"diff",
			"gitcommit",
			"json",
			"latex",
			"lua",
			"markdown",
			"ruby",
			"scss",
			"xml",
			"yuck",
			"zathurarc",
		},
	},
	config = function(_, opts)
		local configs = require("nvim-treesitter.configs")
		configs.setup(opts)
	end,
}
