-- Título de la ventana: Título del archivo
vim.opt.title = true
-- Codificación de caracteres: UTF-8
vim.opt.encoding = "utf-8"
-- Permitir el uso del mouse en todos los modos
vim.opt.mouse = "a"
-- Desactivar ctags
vim.opt.tags = "/dev/null"
-- Cambiar de buffer sin guardar los cambios
vim.opt.hidden = true
-- Cambiar el directorio de trabajo al del archivo
vim.opt.autochdir = true
-- Tiempo de espera entre teclas
vim.opt.ttimeoutlen = 0
-- Navegación y autocompletado de comandos
vim.opt.wildmode = "longest,list,full"
-- Altura máxima del menú de autocompletado
vim.opt.pumheight = 10
-- Añadir márgenes en los extremos de la ventana
vim.opt.scrolloff = 5
-- Desactiva el ajuste de línea
vim.opt.wrap = true
-- Una sola barra de estado para todas las ventanas
vim.opt.laststatus = 3
-- Opciones del cursor
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
-- Ajustes de búsqueda
vim.opt.ignorecase = true
vim.opt.incsearch = true
-- Líneas de separación vertical y caracteres invisibles
vim.opt.list = true
vim.opt.listchars = { tab = "| ", trail = "·", lead = "·", precedes = "<", extends = ">" }
-- Marcar la columna 80
vim.opt.colorcolumn = "80"

-- Permitir el acceso global al porta-papeles
vim.opt.clipboard:append("unnamedplus")

-- Borrar automáticamente los espacios sobrantes al guardar
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		local currPos = vim.fn.getpos(".")
		vim.cmd("%s/\\s\\+$//e") -- Eliminar espacios al final de las líneas
		vim.cmd("%s/\\n\\+\\%$//e") -- Eliminar saltos de línea al final del archivo
		vim.fn.cursor(currPos[2], currPos[3]) -- Restaurar la posición del cursor
	end,
})
