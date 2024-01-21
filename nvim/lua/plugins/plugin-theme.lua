return{
	{
		"neanias/everforest-nvim",
		version=false,
		lazy=false,
		pririty=1000,
		config=function()
			require("everforest").setup({

			})
		end,
	}, 
	{
		"shaunsingh/nord.nvim",
		version="*",
		lazy = false,
		priority = 1000,
		config = function()
		end,
	},
} 

