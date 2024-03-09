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
-- 本地变量保存提前量
local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

-- leader key
map("","<Space>","<Nop>",opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


----------------------------
--------- 究极快捷 ---------
----------------------------

-- 退出
map('n','<A-j>','<ESC>',opts)
map('i','<A-j>','<ESC>',opts)
map('v','<A-j>','<ESC>',opts)


----------------------------
--------- 快速移动 ---------
----------------------------

-- 1. 多行/字符移动
map("n","<leader>j","15j",opts)
map("n","<leader>k","15k",opts)
map("n","<leader>;","10h",opts)
map("n","<leader>'","10l",opts)
-- 2. Visule代码移动
-- 2.1 缩进代码
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts) 
-- 2.2 上下移动选中文本
map("v", "J", ":move '>+1<CR>gv-gv", opts)
map("v", "K", ":move '<-2<CR>gv-gv", opts)
-- 2.3 visual模式下禁止粘贴
map("v", "p","_dP",opts)


----------------------------
--------- 窗口管理 ---------
----------------------------

-- 取消s默认功能
map("n","s","",opts)

-- 1. 创建窗口
--- 1.1 创建横向窗口
map("n","<leader>ws","<C-w>s",opts)
--- 1.2 创建纵向窗口
map("n","<leader>wv","<C-w>v",opts)

-- 2. 关闭与离开窗口
--- 2.1 关闭当前窗口
map("n","<leader>wc","<C-w>c",opts)
--- 2.2 离开当前窗口
map("n","<leader>wq","<C-w>q",opts)
--- 2.3 关闭当前窗口以外的所有窗口
map("n","<leader>wo","<C-w>o",opts)

-- 3. 窗口游走
--- 3.1 四个方向游走
map("n","<leader>wj","<C-w>j",opts)
map("n","<leader>wk","<C-w>k",opts)
map("n","<leader>wh","<C-w>h",opts)
map("n","<leader>wl","<C-w>l",opts)

-- 4. 跳转Tab
-- 需要bufferline插件
--- 4.1 跳转至左侧buffer
-- map("n","<C-h>","gT",opts)
map("n", "<C-h>", ":BufferLineCyclePrev<CR>", opts)
--- 4.2 跳转至右侧buffer
-- map("n","<C-l>","gt",opts)
map("n", "<C-l>", ":BufferLineCycleNext<CR>", opts)

-- 5. 关闭buffer
--- 5.1 关闭当前buffer，且不打乱buffer布局
--- 需要vim-bbye插件
map("n", "<A-x>", ":Bdelete!<CR>", opts)
--- 5.2 关闭当前buffer左侧buffer
map("n", "<leader>bh", ":BufferLineCloseLeft<CR>", opts)
--- 5.3 关闭当前buffer右侧buffer
map("n", "<leader>bl", ":BufferLineCloseRight<CR>", opts)
--- 5.4 关闭当前buffer
map("n", "<leader>bc", ":BufferLinePickClose<CR>", opts)

-- 6. 窗口大小调整
-- 向上
map("n","<C-Up>",":resize +2<CR>", opts)
-- 向下
map("n","<C-Down>",":resize -2<CR>", opts)
-- 向左
map("n","<C-Left>",":vertical resize -2<CR>", opts)
-- 向右
map("n","<C-Right>",":vertical resize +2<CR>", opts)



----------------------------
------- 插件快捷管理 -------
----------------------------

-- Neo-tree
-- 1. 打开文件管理侧边栏
map("n","<leader><leader>pr",":Neotree<CR>",opts)
-- 2. 关闭文件管理侧边栏
map("n","<S-n>",":Neotree close<CR>",opts)

