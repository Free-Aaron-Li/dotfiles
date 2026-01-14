return {
    {
        'nvim-lualine/lualine.nvim',
				dependencies = {
					'nvim-tree/nvim-web-devicons',
					'arkav/lualine-lsp-progress',
				},
        config = function()
					require('lualine').setup({
						options={
							theme = 'solarized', -- nord,solarized,
							component_separators = { left = "|", right = "|" },
							-- https://github.com/ryanoasis/powerline-extra-symbols
							section_separators = { left = " ", right = "" },
						},
						sections = {
							lualine_c = {
								"filename",
								{
									"lsp_progress",
									spinner_symbols = { " ", " ", " ", " ", " ", " " },
								},
							},
							lualine_x = {
								"filesize",
								{
									"fileformat",
									symbols = {
										unix = '', -- e712
										dos = '', -- e70f
										mac = '', -- e711
									},
									-- symbols = {
									--	unix = "LF",
									--	dos = "CRLF",
									--	mac = "CR",
									-- },
								},
								"encoding",
								"filetype",
							},
						},
					})
        end
    }
}
