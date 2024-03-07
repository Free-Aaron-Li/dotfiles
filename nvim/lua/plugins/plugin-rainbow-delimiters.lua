return{
	{
		'hiphish/rainbow-delimiters.nvim',
		config = function()
			local rainbow_delimiters = require 'rainbow-delimiters'
			---@type rainbow_delimiters.config
			vim.g.rainbow_delimiters = {}
		end
	}
}
