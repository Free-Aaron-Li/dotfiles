return{
	'chomosuke/typst-preview.nvim',
	lazy = false, -- or ft = 'typst'
	version = '0.1.*',
	build = function() 
		require 'typst-preview'.update() 
		require 'typst-preview'.setup({
			debug=true,
			get_root = function(bufnr_of_typst_buffer)
				return vim.fn.getcwd()
			end,
		})
	end,
}
