return{
	{
    -- 森林主题
		"neanias/everforest-nvim",
		version=false,
		lazy=false,
	}, 
	{
    -- 现代化主题
		"shaunsingh/nord.nvim",
		version="*",
		lazy = false,
		priority = 1000,
		config = function()
			--	对比度，让侧边栏和弹出窗口具有与编辑页面不同的背景
			vim.g.nord_contrast = true
			-- 边界，使得垂直分割窗口之间的边界可见
			vim.g.nord_borders = true
			-- 彩色背景，在diff模式下启用/禁止彩色背景
			vim.g.nord_uniform_diff_background = true
			-- 斜体
			vim.g.nord_italic = false

		require("headlines").setup({
			markdown = {
        headline_highlights = {
          "Headline1",
          "Headline2",
          "Headline3",
          "Headline4",
          "Headline5",
          "Headline6",
        },
        codeblock_highlight = "CodeBlock",
        dash_highlight = "Dash",
				quote_highlight = "Quote",
			},
		})
		end,
	},
  {
    -- 纸张主题
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    -- 夜晚东京
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
} 

