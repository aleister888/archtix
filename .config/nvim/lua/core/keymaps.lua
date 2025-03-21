vim.keymap.set("n", "<leader>wq", ":wq<CR>")
vim.keymap.set("n", "<leader>qq", ":q!<CR>")
vim.keymap.set("n", "<leader>qa", ":qa!<CR>")
vim.keymap.set("n", "<leader>ww", ":w<CR>")

vim.keymap.set("n", "<leader><BS>", ":noh<CR>", { silent = true })

vim.keymap.set("n", "<leader>v", "<C-w>v")
vim.keymap.set("n", "<leader>V", "<C-w>s")

-- Desplazarse por el texto
vim.keymap.set("n", "<ScrollWheelUp>", "k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-ScrollWheelUp>", "5k", { noremap = true, silent = true })

vim.keymap.set("n", "<ScrollWheelDown>", "j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-ScrollWheelDown>", "5j", { noremap = true, silent = true })

vim.keymap.set("n", "<C-Up>", "5k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Down>", "5j", { noremap = true, silent = true })

vim.keymap.set("n", "=", "$", { noremap = true, silent = true })
vim.keymap.set("v", "=", "$h", { noremap = true, silent = true })

-- Encapsular texto seleccionado
vim.keymap.set("v", '"', 's"<C-r>""', { noremap = true, silent = true })
vim.keymap.set("v", "'", "s'<C-r>\"'", { noremap = true, silent = true })
vim.keymap.set("v", "`", 's`<C-r>"`', { noremap = true, silent = true })
vim.keymap.set("v", "$", 's$<C-r>"$', { noremap = true, silent = true })
vim.keymap.set("v", "(", 's(<C-r>")', { noremap = true, silent = true })
vim.keymap.set("v", ")", 's(<C-r>")', { noremap = true, silent = true })
vim.keymap.set("v", "{", 's{<C-r>"}', { noremap = true, silent = true })
vim.keymap.set("v", "}", 's{<C-r>"}', { noremap = true, silent = true })
vim.keymap.set("v", "[", 's[<C-r>"]', { noremap = true, silent = true })
vim.keymap.set("v", "]", 's[<C-r>"]', { noremap = true, silent = true })
vim.keymap.set("v", "¿", 's¿<C-r>"?', { noremap = true, silent = true })
vim.keymap.set("v", "?", 's¿<C-r>"?', { noremap = true, silent = true })

-- Cambiar entre ventanas
vim.keymap.set("n", "<leader>s", "<C-w>w", { noremap = true, silent = true })

-- Spawnear scratchpad
vim.keymap.set("n", "<leader>S", function()
	local terminal = os.getenv("TERMINAL") or ""
	local termtitle = os.getenv("TERMTITLE") or ""
	local cmd = string.format('setsid -f sh -c "%s %s scratchpad"', terminal, termtitle)
	vim.fn.execute("!" .. cmd)
end, { silent = true })
