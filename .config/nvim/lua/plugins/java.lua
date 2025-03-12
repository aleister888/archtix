return {
	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		config = function()
			local config = {
				cmd = {
					vim.fn.expand("$HOME/.local/share/nvim/mason/bin/jdtls"),
					("--jvm-arg=-javaagent:%s"):format(
						vim.fn.expand("$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar")
					),
				},
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
				data_dir = vim.fn.stdpath("cache") .. "/jdtls",
				root_dir = require("jdtls.setup").find_root({ ".git", "pom.xml", "build.gradle" }),
			}

			require("jdtls").start_or_attach(config)
		end,
	},
	{
		"nvim-neotest/neotest",
		ft = "java",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"rcasia/neotest-java",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-java"),
				},
			})

			local function download_junit_jar()
				local jar_name = "junit-platform-console-standalone-1.10.1.jar"
				local junit_jar_path = vim.fn.expand("~/.local/share/nvim/neotest-java/") .. jar_name

				-- Verificar si el archivo JAR ya existe
				if vim.fn.filereadable(junit_jar_path) == 0 then
					-- Si el archivo no existe, usar wget para descargarlo
					local url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/1.10.1/"
						.. jar_name
					local cmd = "wget -O " .. junit_jar_path .. " " .. url .. " >/dev/null 2>&1"
					os.execute(cmd)
				end
			end
			-- Llamar a la función para descargar el JAR
			download_junit_jar()

			-- Ejecutar test
			vim.api.nvim_set_keymap(
				"n",
				"<leader>xr",
				[[:lua require("neotest").run.run(vim.fn.expand("%"))<CR>]],
				{ noremap = true, silent = true }
			)
			-- Mostrar/ocultar interfaz
			vim.api.nvim_set_keymap(
				"n",
				"<leader>xt",
				[[<CR>:lua require("neotest").summary.toggle()<CR>]],
				{ noremap = true, silent = true }
			)
		end,
	},
}
