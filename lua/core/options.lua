-- 字体(Nerd字体，支持连字符)
-- 在neovide个性化选项中设置（toggleime.lua）
-- vim.o.guifontwide = "霞鹜文楷等宽:h12" -- neovide下不起作用，直接写到guifont中
-- https://github.com/neovide/neovide/issues/1729
-- vim.o.ambiwidth = "double"

-- 行号
-- vim.o.relativenumber = true
vim.o.number = true

-- 命令行设置
-- vim.o.cmdheight = 0

-- vim.o.shellslash = true
vim.o.autowrite = true -- 自动写入

-- 缩进
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true

vim.o.jumpoptions = "stack" -- 跳转历史用堆栈模式

-- 不换行
-- vim.o.wrap = true

-- vim.o.foldmethod = "indent"
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.o.foldlevel = 1
vim.o.foldlevelstart = 1
vim.o.foldenable = false

-- ufo插件
-- vim.o.foldcolumn = "1" -- '0' is not bad
-- vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
-- vim.o.foldlevelstart = 99
-- vim.o.foldenable = true
-- -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
-- vim.keymap.set("n", "zR", require("ufo").openAllFolds)
-- vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

-- 行内全量替换
vim.o.gdefault = true

-- 光标行
vim.o.cursorline = true

-- 启用鼠标
-- vim.o.mouse:append("a")
vim.o.mouse = "a"

-- 状态栏已经显示模式，无需再额外显示
vim.o.showmode = false

-- 隐藏tabline，否则可用mini.tabline来管理
-- vim.o.showtabline = 0

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- 系统剪贴板
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
-- vim.o.clipboard:append("unnamedplus")

-- 默认新窗口右和下
vim.o.splitright = true
vim.o.splitbelow = true

-- 搜索
vim.o.ignorecase = true
vim.o.smartcase = true

-- 外观
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
-- vim.cmd[[colorscheme tokyonight-moon]]
vim.o.colorcolumn = "80,120"

-- 滚动时上下预留行数，极大值可确保n/N查找时定位到屏幕中间
-- vim.o.scrolloff = 999

-- Decrease update time
vim.o.updatetime = 200

-- subsitutions live preview
vim.o.inccommand = "split"

-- 按键超时间隔（毫秒）
-- vim.o.timeoutlen = 600

-- vim.o.confirm = true

-- listchars仍然需要用opt访问
-- vim.o.list = true
-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- 会话保存autosession插件（blank,folds,help,globals,options,skiprtp.resize,sesdir）
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,winpos,terminal,localoptions"

-- 字符集设置，可尝试重新加载文件:e ++enc=gbk，GB18030是GBK的超集
vim.o.fileencodings = "ucs-bom,utf-8,gb18030,utf-16le,big5,euc-jp,euc-kr,latin1"

--vim插件相关全局变量设置
-- cmp-spell插件需要打开spell
-- vim.opt.spell = true
-- vim.opt.spelllang = { "en_us" }

-- 禁用诊断虚拟文本
-- vim.diagnostic.config({
-- 	virtual_text = false, -- 禁用虚拟文本
-- 	signs = true, -- 保留侧边栏的标记
-- 	update_in_insert = false,
-- 	underline = false, -- 是否保留代码下方的波浪线
-- })

-- 光标停留在某一行时，通过悬浮窗口显示诊断信息
-- vim.api.nvim_create_autocmd("CursorHold", {
-- 	pattern = "*",
-- 	callback = function()
-- 		vim.diagnostic.open_float({ header = "", scope = "line" })
-- 	end,
-- })

-- 配置python可执行文件，需要安装pynvim，以便可运行python开发的插件
vim.g.python3_host_prog = "C:/Users/luocm/AppData/Local/Programs/Python/Python39/python.exe"
vim.g.nayvy_import_config_path = "C:/utility/misc/import_config.nayvy"
vim.g.nayvy_pyproject_root_markers = {
	"pyproject.toml",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
}

--vista插件
-- vim.g.vista_sidebar_width = 25

-- colorscheme相关插件
vim.g.everforest_disable_italic_comment = 1
vim.g.gruvbox_material_disable_italic_comment = 1
-- vim.g.sonokai_enable_italic = false
vim.g.sonokai_disable_italic_comment = 1

-- vim-dadbod-ui配置
vim.g.dbs = {
	-- { name = "dev", url = "postgres://postgres:mypassword@localhost:5432/my-dev-db" },
	-- { name = "staging", url = "postgres://postgres:mypassword@localhost:5432/my-staging-db" },
	{ name = "mysql", url = "mysql://root:root@localhost/world" },
	-- {
	-- 	name = "production",
	-- 	url = function()
	-- 		return vim.fn.system("get-prod-url")
	-- 	end,
	-- },
}

-- vim-translator翻译插件，引擎剔除'google'，无法访问导致插件响应特别慢
vim.g.translator_default_engines = { "bing", "haici", "youdao" }

-- rest.nvim配置
---@type rest.Opts
-- vim.g.rest_nvim = {
-- 	-- ...
-- }

-- molten-nvim插件
-- vim.g.python3_host_prog = vim.fn.expand("C:/utility/.venv/neovim/Scripts/python.exe")
