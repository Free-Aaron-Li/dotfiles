-- 备注
-- vim.api.nvim_set_keymap() 全局快捷键
-- vim.api.nvim_buf_set_keymap() Buffer快捷键
--
-- 参数：vim.api.nvim_set_keymap('模式','按键‘，’映射为‘，’选项‘)
-- 模式：
-- Normal模式，n
-- Insert模式，i
-- Visual模式，v
-- Terminal模式，t
-- Command模式，c

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 本地变量保存提前量
local map = vim.api.nvim_set_keymap
local opt = {noremap = true, silent = true}


-- 退出
map('n','<A-j>','<ESC>',opt)
map('i','<A-j>','<ESC>',opt)
map('v','<A-j>','<ESC>',opt)
