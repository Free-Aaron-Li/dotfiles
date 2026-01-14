if vim.g.neovide then
	-------------------------- 
	---------- 显示 ----------
	--------------------------
	
	--------
	-- 参考：https://neovide.dev/
	--------
	
	-- 1. 字体
  -- vim.o.guifont = "JetBrains Mono,Noto Color Emoji,LXGW WenKai:h14"
	vim.o.guifont = "MeowSansNerd:h14"
	-- 2. 行间距 
	vim.o.linespace = 0
	-- 3. Scale
	vim.g.neovide_scale_factor = 1.0
	-- 4. 窗口边框
	-- 由背景色填充
	vim.g.neovide_padding_top = 0
	-- 5. 窗口透明
	vim.g.neovide_transparency = 1.0
	-- 6. 动画 
	-- 6.1 滚动动画长度
	vim.g.neovide_scroll_animation_length = 0.4
	-- 6.2 光标动画长度
	vim.g.neovide_cursor_animation_length = 0.05
	-- 6.3 光标动画轨迹大小
	vim.g.neovide_cursor_trail_size = 0.8
	-- 6.4 插入模式下启用动画
	vim.g.neovide_cursor_animate_in_insert_mode = true
	-- 6.5 动画切换
	-- 从插入模式切换到命令模式显示动画
	vim.g.neovide_cursor_animate_command_line = true
	-- 7. 滚动线
	vim.g.neovide_scroll_animation_for_lines = 9999
	-- 8. 打字时隐藏鼠标
	vim.g.neovide_hide_mouse_when_typing = true
	-- 9. 下划线自动缩放
	vim.g.neovide_underline_stroken_scale = 1.0
	-- 10. 光标抗锯齿
	vim.g.neovide_cursor_antialiasing = true


	-------------------------- 
	---------- 主题 ----------
	--------------------------
	
	vim.g.neovide_theme = 'auto'

	-------------------------- 
	---------- 杂项 ----------
	--------------------------
	
	-- 1. 确认退出
	vim.g.neovide_confirm_quit = true
	-- 2. 全屏
	vim.g.neovide_fullscreen = true
	-- 3. 记住上一个窗口大小
	vim.g.neovide_remember_window_size = true
	-- 4. 禁用IME输入
	-- 仅在输入模式和搜索时启用IME输入法，简化导航。
	local function set_ime(args)
    if args.event:match("Enter$") then
        vim.g.neovide_input_ime = true
    else
        vim.g.neovide_input_ime = false
    end
	end

	local ime_input = vim.api.nvim_create_augroup("ime_input", { clear = true })

	vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    group = ime_input,
    pattern = "*",
    callback = set_ime
	})

	vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    group = ime_input,
    pattern = "[/\\?]",
    callback = set_ime
	})


	-------------------------- 
	-------- 粒子特效 --------
	--------------------------
	
	-- 1. 样式选择
	-- 没有 ""
	-- 轨道炮 "railgun"
	-- 鱼雷 "torpedo"
	-- 精灵 "pixiedust"
	-- 音爆 "sonicboom"
	-- 涟漪 "ripple"
	-- 线框 "wireframe"
	vim.g.neovide_cursor_vfx_mode = "railgun"

	-- 2. 粒子不透明度
	vim.g.neovide_cursor_vfx_opacity = 200.0

	-- 3. 粒子寿命
	vim.g.neovide_cursor_vfx_particle_lifetime = 1.2

	-- 4. 粒子密度
	vim.g.neovide_cursor_vfx_particle_density = 10.0

	-- 5. 粒子速度
	vim.g.neovide_cursor_vfx_particle_speed = 10.0

	-- 6. 粒子相
	-- 仅支持“railgun”样式
	-- 粒子质量移动，行为方式。
	-- 值越高，粒子彼此一致旋转的次数越少；值越低，所有粒子的直线方向越多
	vim.g.neovide_cursor_vfx_particle_phase = 1.5

	-- 7. 粒子卷曲
	-- 仅支持“railgun”样式
	-- 粒子旋转速度
	-- 值越高，粒子实际移动的越少，看起来越“紧张”；值越低，看起来就越像一个崩溃的正弦波
	vim.g.neovide_cursor_vfx_particle_curl = 1.0
end
