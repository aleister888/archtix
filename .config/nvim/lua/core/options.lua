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

-- Clipboard: permitir acceso global si no estamos en 'root'
if os.getenv("USER") ~= "root" then
	vim.opt.clipboard:append("unnamedplus")
end

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

-- Directorio de plantillas
local template_dir = vim.fn.stdpath("config") .. "/templates"

-- Función para cargar la plantilla
local function load_template(filename)
	local template_file = template_dir .. "/" .. filename

	-- Verifica si el archivo de plantilla existe
	if vim.fn.filereadable(template_file) == 1 then
		vim.cmd("0r " .. template_file) -- Carga el archivo en el buffer
	end
end

-- Autocmd para cargar la plantilla al crear cualquier nuevo archivo
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*", -- Se activa para cualquier archivo nuevo
	callback = function()
		-- Obtiene el nombre del archivo sin extensión
		local filename = vim.fn.expand("%:t") -- Nombre del archivo sin path

		-- Carga la plantilla si existe un archivo con ese nombre en el directorio templates
		load_template(filename)
	end,
})
