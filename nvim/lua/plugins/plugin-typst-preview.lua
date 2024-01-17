return{
	'chomosuke/typst-preview.nvim',
	lazy = false, -- or ft = 'typst'
	version = '0.1.*',
	build = function() 
		require 'typst-preview'.setup({
			debug=false,
			get_root = function(bufnr_of_typst_buffer)
				return vim.fn.getcwd()
			end,
		})
	end,
}
