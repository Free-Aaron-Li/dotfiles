return{
	{
		'sindrets/diffview.nvim',
		config=function()
			local set = vim.opt -- set options
			set.fillchars = set.fillchars + 'diff:╱'
		end
	}
}
