return{
	{
		-- ref: https://github.com/keaising/im-select.nvim
    "keaising/im-select.nvim",
    config = function()
      require("im_select").setup({
				-- 默认IM输入选择
				default_im_select = "keyboard-us",
				-- 默认执行命令
				default_command = "fcitx5-remote",
				-- 触发默认输入事件
				set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
				-- 恢复之前使用的IM输入
				set_previous_events = { "InsertEnter" },
				-- 当二进制文件丢失，显示如何安装的通知
				keep_quiet_on_no_binary = false,
				-- 异步运行默认执行命令
				async_switch_im = true,
			})
    end,
	}
}
