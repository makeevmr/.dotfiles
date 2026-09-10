local navic = require("nvim-navic")

require('lualine').setup {
	options = {
		theme = 'tokyonight',
		component_separators = { left = '', right = '' },
		section_separators = { left = '', right = '' },
	},
	sections = {
		lualine_c = {
			{ 'filename' },
			{
				function()
					return navic.get_location()
				end,
				cond = function()
					return navic.is_available()
				end
			},
		},
		lualine_x = {},
		lualine_y = { 'progress' },
		lualine_z = { 'location' }
	}
}
