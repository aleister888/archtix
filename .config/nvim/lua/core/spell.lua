-- Alternar corrección ortográfica en español con F4
vim.keymap.set("n", "<F4>", ":setlocal spell! spelllang=es_es<CR>", { silent = false })
vim.keymap.set("i", "<F4>", "<C-O>:setlocal spell! spelllang=es_es<CR>", { silent = false })

-- Alternar corrección ortográfica en inglés con F5
vim.keymap.set("n", "<F5>", ":setlocal spell! spelllang=en_us<CR>", { silent = true })
vim.keymap.set("i", "<F5>", "<C-O>:setlocal spell! spelllang=en_us<CR>", { silent = true })

local spell_dir = vim.fn.stdpath("config") .. "/spell"
local dict_files = {
	{ src = "/usr/share/hunspell/es_ES.aff", dest = spell_dir .. "/es_ES.aff" },
	{ src = "/usr/share/hunspell/es_ES.dic", dest = spell_dir .. "/es_ES.dic" },
	{ src = "/usr/share/hunspell/en_US.aff", dest = spell_dir .. "/en_US.aff" },
	{ src = "/usr/share/hunspell/en_US.dic", dest = spell_dir .. "/en_US.dic" },
}

-- Crear el directorio para los diccionarios si no existe
if vim.fn.isdirectory(spell_dir) == 0 then
	vim.fn.mkdir(spell_dir, "p")
end

-- Copiar los archivos de diccionario si no existen
for _, file in ipairs(dict_files) do
	if vim.fn.filereadable(file.src) == 1 and vim.fn.filereadable(file.dest) == 0 then
		vim.fn.system({ "cp", file.src, file.dest })
	end
end
