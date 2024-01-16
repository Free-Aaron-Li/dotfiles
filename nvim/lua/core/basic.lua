-- 编码格式
vim.g.encoding = "UTF-8"
vim.o.fileencoding = 'utf-8'

-- 相对行号和相对范围
-- 使用相对行号
vim.wo.number = true
vim.wo.relativenumber = true
-- 相对范围
vim.o.scrolloff = 10
vim.o.sidescrolloff = 10


-- 高亮与参考
-- 高亮所在行
vim.wo.cursorline = false
-- 搜索不要高亮
vim.o.hlsearch = false
-- 显示左侧图标指示列
vim.wo.signcolumn = "yes"
-- 右侧参考线，超过表示代码太长了，考虑换行
vim.wo.colorcolumn = "120"

-- 缩进
-- 缩进4个空格等于一个Tab
vim.o.tabstop = 4
vim.bo.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftround = true
-- >> << 缩进
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4
-- 空格替代tab
vim.o.expandtab = false
vim.bo.expandtab = false

-- 对齐
-- 新行对齐当前行
vim.o.autoindent = true
vim.bo.autoindent = true
vim.o.smartindent = true

-- 搜索
-- 搜索大小写不敏感，除非包含大写
vim.o.ignorecase = true
vim.o.smartcase = true
-- 边输入边搜索
vim.o.incsearch = true

-- 页面
-- 命令行高
vim.o.cmdheight = 1
-- 当文件被外部程序修改时，自动加载
vim.o.autoread = true
vim.bo.autoread = true
-- 禁止折行
vim.wo.wrap = false
-- 光标在行首尾时<Left><Right>可以跳到下一行
vim.o.whichwrap = '<,>,[,]'
-- 允许隐藏被修改过的buffer
vim.o.hidden = true
-- 鼠标支持
vim.o.mouse = "a"
-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
-- 智能刷新时间
vim.o.updatetime = 300
-- 等待键盘快捷键连击时间
vim.o.timeoutlen = 500
-- split window 出现方式
-- 下面和右面
vim.o.splitbelow = true
vim.o.splitright = true
-- 自动补全不自动选中
vim.g.completeopt = "menu,menuone,noselect,noinsert"
-- 样式
vim.o.background = "dark"
vim.o.termguicolors = true
vim.opt.termguicolors = true
-- 不可见字符的显示
vim.o.list = false
-- 将空格设为·
vim.o.listchars = "space:·"
-- 补全增强
vim.o.wildmenu = true
-- Dont' pass messages to |ins-completin menu|
vim.o.shortmess = vim.o.shortmess .. 'c'
-- 补全最多显示行数
vim.o.pumheight = 10
-- 永远显示 tabline
vim.o.showtabline = 2
-- 使用增强状态栏插件后不再需要 vim 的模式提示
vim.o.showmode = false
-- 外观
vim.o.termguicolors=true
-- vim.o.signcolumn=true
-- 系统剪切板
-- vim.o.clipboard:append("unnamedplus")
