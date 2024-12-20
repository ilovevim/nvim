local opt = vim.opt

-- 字体(Nerd字体，支持连字符)
-- 在neovide个性化选项中设置（toggleime.lua）
-- vim.o.guifontwide = "霞鹜文楷等宽:h12" -- neovide下不起作用，直接写到guifont中
-- https://github.com/neovide/neovide/issues/1729
-- opt.ambiwidth = "double"

-- 行号
-- opt.relativenumber = true
opt.number = true

-- 命令行设置
-- opt.cmdheight = 0

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.jumpoptions = "stack" -- 跳转历史用堆栈模式

-- 不换行
opt.wrap = false

-- 折叠，参考B友“敲代码的脱发水”——代码折叠设置
-- opt.foldmethod = "indent"
opt.foldmethod = "expr" -- fold with nvim_treesitter
opt.foldexpr = "nvim_treesitter#foldexpr()"
-- opt.foldlevel = 1
opt.foldenable = false

-- 行内全量替换
opt.gdefault = true

-- 光标行
opt.cursorline = true

-- 启用鼠标
opt.mouse:append("a")

-- 状态栏已经显示模式，无需再额外显示
opt.showmode = false

-- 隐藏tabline，否则可用mini.tabline来管理
-- opt.showtabline = 0

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- 系统剪贴板
-- opt.clipboard:append("unnamedplus")
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"
-- vim.cmd[[colorscheme tokyonight-moon]]

-- Decrease update time
opt.updatetime = 250

-- 按键超时间隔（毫秒）
-- opt.timeoutlen = 300

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
-- opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- 会话保存autosession插件
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

--vim插件相关全局变量设置
-- cmp-spell插件需要打开spell
-- vim.opt.spell = true
-- vim.opt.spelllang = { "en_us" }

--vista插件
-- vim.g.vista_sidebar_width = 25

-- colorscheme相关插件
vim.g.everforest_disable_italic_comment = 1
vim.g.gruvbox_material_disable_italic_comment = 1
-- vim.g.sonokai_enable_italic = false
vim.g.sonokai_disable_italic_comment = 1
