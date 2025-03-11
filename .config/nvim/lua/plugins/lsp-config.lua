local servers = {
	"lua_ls",
	"texlab",
	"bashls",
	"markdown_oxide",
	"cssls",
	"jdtls",
}

return {
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = function()
			vim.keymap.set("n", "<leader>A", vim.lsp.buf.code_action, {})
			-- Mostrar diagnóstico en una ventana flotante
			vim.api.nvim_set_keymap(
				"n",
				"<leader>d1",
				":lua vim.diagnostic.open_float()<CR>",
				{ noremap = true, silent = true }
			)
			-- Mostrar diagnósticos en forma de lista
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dl",
				":lua vim.diagnostic.setqflist()<CR>",
				{ noremap = true, silent = true }
			)
			-- Ir al siguiente diagnóstico
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dn",
				":lua vim.diagnostic.goto_next()<CR>",
				{ noremap = true, silent = true }
			)
			-- Ir al diagnóstico anterior
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dp",
				":lua vim.diagnostic.goto_prev()<CR>",
				{ noremap = true, silent = true }
			)
			return {
				ensure_installed = servers,
			}
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- Configurar servidores LSP
			for _, lsp in ipairs(servers) do
				if lsp ~= "jdtls" then
					lspconfig[lsp].setup({
						capabilities = capabilities,
					})
				end
			end
			require("mason-tool-installer").setup({
				ensure_installed = { "java-debug-adapter", "java-test" },
				auto_update = true,
				run_on_start = true,
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- Para LSP
			"quangnguyen30192/cmp-nvim-ultisnips", -- Para ultisnips
			"L3MON4D3/LuaSnip", -- Dependencia de snippets
			"hrsh7th/cmp-buffer", -- Autocompletado desde el buffer
			"hrsh7th/cmp-path", -- Autocompletado de rutas
			"hrsh7th/cmp-nvim-lua", -- Autocompletado para Lua
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			-- Setup de nvim-cmp
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
						vim.fn["UltiSnips#Anon"](args.body)
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "ultisnips" },
					{ name = "buffer" },
					{ name = "path" },
					{ name = "nvim_lua" },
				},
				mapping = {
					-- Shift+Tab para confirmar selección
					["<S-Tab>"] = cmp.mapping.confirm({ select = true }),
					-- Flecha Abajo para ir a la siguiente opción
					["<Down>"] = cmp.mapping.select_next_item(),
					-- Flecha Arriba para ir a la opción anterior
					["<Up>"] = cmp.mapping.select_prev_item(),
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. (strings[1] or "") .. " "
						kind.menu = "    (" .. (strings[2] or "") .. ")"
						return kind
					end,
				},
			})
		end,
	},
}
