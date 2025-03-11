-- stylua: ignore
local colors = {
	bg =       "#282828",
	fg =       "#a89984",
	yellow =   "#d79921",
	cyan =     "#689d6a",
	darkblue = "#076678",
	green =    "#98971a",
	orange =   "#fe8019",
	violet =   "#b16286",
	magenta =  "#8f3f71",
	blue =     "#458588",
	red =      "#cc241d",
}

local conditions = {
	buffer_not_empty = function()
		return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
	end,
	hide_in_width = function()
		return vim.fn.winwidth(0) > 80
	end,
	check_git_workspace = function()
		local filepath = vim.fn.expand("%:p:h")
		local gitdir = vim.fn.finddir(".git", filepath .. ";")
		return gitdir and #gitdir > 0 and #gitdir < #filepath
	end,
}

local config = {
	options = {
		component_separators = "",
		section_separators = "",
		theme = {
			normal = { c = { fg = colors.fg, bg = colors.bg } },
			inactive = { c = { fg = colors.fg, bg = colors.bg } },
		},
	},
	sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},

		lualine_c = {},
		lualine_x = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = {},
		lualine_x = {},
	},
}

local function ins_left(component)
	table.insert(config.sections.lualine_c, component)
end

local function ins_right(component)
	table.insert(config.sections.lualine_x, component)
end

ins_left({
	function()
		return " "
	end,
	padding = { left = 0, right = 0 },
})

-- Indicador del modo
ins_left({
	function()
		return ""
	end,
	color = function()
		-- Cambiar el color en función del modo en el que nos encontremos
		local mode_color = {
			n = colors.green,
			i = colors.yellow,
			v = colors.blue,
			["␖"] = colors.blue,
			V = colors.blue,
			c = colors.magenta,
			no = colors.red,
			s = colors.orange,
			S = colors.orange,
			["␓"] = colors.orange,
			ic = colors.yellow,
			R = colors.violet,
			Rv = colors.violet,
			cv = colors.red,
			ce = colors.red,
			r = colors.cyan,
			rm = colors.cyan,
			["r?"] = colors.cyan,
			["!"] = colors.red,
			t = colors.red,
		}
		return { fg = mode_color[vim.fn.mode()] }
	end,
	padding = { right = 1 },
})

-- Nombre del archivo
ins_left({
	"filename",
	cond = conditions.buffer_not_empty,
	color = { fg = colors.fg, gui = "bold" },
})

-- Localización dentro del archivo
ins_left({ "location" })

-- Progreso dentro del archivo
ins_left({ "progress", color = { fg = colors.fg, gui = "bold" } })

-- Diagnóstico del LSP
ins_left({
	"diagnostics",
	sources = { "nvim_diagnostic" },
	symbols = { error = " ", warn = " ", info = " " },
	diagnostics_color = {
		error = { fg = colors.red },
		warn = { fg = colors.yellow },
		info = { fg = colors.cyan },
	},
})

-- Muestra si el spellcheck está activado y con que idioma
ins_left({
	function()
		local spell_enabled = vim.opt.spell:get()

		if spell_enabled then
			local spell_lang = vim.opt.spelllang:get()[1]:sub(1, 2) -- Obtiene el idioma del spellcheck
			return "  " .. spell_lang
		else
			return ""
		end
	end,
	cond = conditions.hide_in_width,
	color = { fg = colors.orange, gui = "bold" },
})

-- Mostrar el tipo de archivo
ins_right({
	"filetype",
	fmt = string.upper,
	icons_enabled = false,
	color = { fg = colors.fg, gui = "bold" },
})

-- Mostrar el formato del archivo
ins_right({
	"fileformat",
	fmt = string.upper,
	icons_enabled = false,
	color = { fg = colors.fg, gui = "bold" },
})

-- Mostrar la codificación del archivo
ins_right({
	"o:encoding",
	fmt = string.upper,
	cond = conditions.hide_in_width,
	color = { fg = colors.fg, gui = "bold" },
})

-- Mostrar la rama de desarrollo
ins_right({
	"branch",
	icon = "󰘬",
	color = { fg = colors.yellow, gui = "bold" },
})

-- Mostrar adiciones/sustracciones/modificaciones
ins_right({
	"diff",
	symbols = { added = "+", modified = "~", removed = "-" },
	diff_color = {
		added = { fg = colors.green },
		modified = { fg = colors.orange },
		removed = { fg = colors.red },
	},
	cond = conditions.hide_in_width,
})

ins_right({
	function()
		return " "
	end,
	padding = { left = 0, right = 0 },
})

return {
	"nvim-lualine/lualine.nvim",
	config = config,
}
