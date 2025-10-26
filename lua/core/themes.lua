-- 设置随机数种子（Neovim启动时执行一次）
math.randomseed(os.time())

-- 设置只有neovide才能支持的NerdFont（连字符等），在themes.lua中切换
-- "SpaceMono_Nerd_Font:h12", -- 行间距较大
-- "AnonymicePro_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- 英文字体显小，中文字体对比过大
-- "Inconsolata_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- 英文字体显小，中文字体对比过大
-- "SF_Mono:h12" -- 字体加载报错

-- 以下字体共有问题：Aerial大纲插件中类、函数图标显示异常
-- "Monoisome:h12",
-- "MonacoLigaturized:h12",
-- "Sarasa_Nerd:h12", -- 同名：等距更纱黑体_SC:h12
-- "Hasklig:h12" -- 从SourceCodePro衍生，增加连字符
-- "Noto_Sans_Mono_CJK_SC,等距更纱黑体_SC:h11",
-- "Monoid_Nerd_Font_Mono:h11", -- 老牌编程字体（英文大写比小写大太多）
-- "YaHei_Consolas_Hybrid:h12", -- 微软雅黑+Consolas混合字体（同时支持中英文）
-- "LXGW_Bright_Code:h13", -- Monospace+霞鹜文楷等宽合成字体
local fonts = {
	"BlexMono_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- IBM出品
	"CasCadia_Code_NF,霞鹜文楷等宽:h12",
	"CodeNewRoman_Nerd_Font_Mono,霞鹜文楷等宽:h13",
	"CommitMono_Nerd_Font,等距更纱黑体_SC:h12", -- 以Fira Code和JetBrains Mono为灵感制作nvi
	"EnvyCodeR_Nerd_Font_Mono,霞鹜文楷等宽:h13",
	"FantasqueSansM_Nerd_Font_Mono,霞鹜文楷等宽:h13", -- 英文字体显小，中文字体对比过大
	"FiraCode_Nerd_Font,等距更纱黑体_SC:h12",
	"GeistMono_NFM,霞鹜文楷等宽:h12",
	"Google_Sans_Code_NF,霞鹜文楷等宽:h12",
	"Hack_Nerd_Font_Mono,霞鹜文楷等宽:h12",
	"Hurmit_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- 专为编码设计
	"IntoneMono_NFM,霞鹜文楷等宽:h12",
	"Iosevka_NFM,霞鹜文楷等宽:h13", -- 中文版即为Sarasa（等距更纱黑体）
	"JetBrainsMono_NF,等距更纱黑体_SC:h12",
	"Maple_Mono_Normal_NF_CN:h12",
	"MesloLGMDZ_Nerd_Font_Mono,等距更纱黑体_SC:h12", -- 苹果专用开发者字体（Line Gap, Medium, Dotted zero）
	"Monaspace_Argon_NF,霞鹜文楷等宽:h12",
	"Mononoki_Nerd_Font_Mono,霞鹜文楷等宽:h13",
	"RecMonoLinear_Nerd_Font_Mono,霞鹜文楷等宽:h12",
	"RobotoMono_Nerd_Font_Mono,等距更纱黑体_SC:h12",
	"SauceCodePro_NFM,等距更纱黑体_SC:h12", -- 英文字体显小，显得中文字体过大
	"UbuntuMono_Nerd_Font_Mono,等线:h13", -- Ubuntu系统专用字体，英文字体太小
	"VictorMono_NFM,霞鹜文楷等宽:h12", -- 字体太细
}

-- 自选颜色得到主题
-- "molokai", "neosolarized", "ayu", "oxocarbon", "OceanicNext", "modus",
-- horizon字体太红
local themes = {
	"bluloco",
	"catppuccin",
	"dracula",
	"everforest",
	"github_dark_dimmed",
	"gruvbox-material",
	"hybrid",
	"jellybeans",
	"kanagawa",
	"melange",
	"miasma",
	"monokai-pro",
	"nightfox",
	"one",
	"onedark",
	"onenord",
	"palenightfall",
	"PaperColor",
	"rose-pine",
	"sonokai",
	"tokyonight",
	"vscode",
	"zephyr",
}

-- 字体、颜色索引，lua中数组下标从1开始
local font_idx = 0 -- math.random(#fonts)
local theme_idx = 0 -- math.random(#themes)

-- 按步长step循环迭代idx，以len为限
-- 若idx为0，表示首次进入，取1-n之间随机数
local function loop_index(idx, len, step)
	idx = (idx + step) % len
	-- 取模后可能为0，重定向为最后一个元素
	if idx == 0 then
		idx = len
	end
	return idx
end

-- 随机打乱表格顺序
local function shuffle_table(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

-- 打乱表格顺序，每次启动后随机切换效果
shuffle_table(fonts)
shuffle_table(themes)

local M = {}

-- 循环切换字体
M.switch_font = function(step)
	step = step or 1 -- 设置默认值
	font_idx = loop_index(font_idx, #fonts, step)
	vim.o.guifont = fonts[font_idx]
end

-- 循环切换主题
M.switch_theme = function(step)
	step = step or 1 -- 设置默认值
	theme_idx = loop_index(theme_idx, #themes, step)
	vim.api.nvim_command("colorscheme " .. themes[theme_idx]) -- .. "|redraw!")
end

-- 增减字号大小
M.change_font_size = function(step)
	local font_str = fonts[font_idx]
	local size_str = font_str:match("h(%d+)$")
	if not size_str then
		vim.notify("Font size not specified: " .. font_str)
		return
	end
	local new_size = tonumber(size_str) + step

	-- 限制字体大小范围
	new_size = math.max(8, math.min(15, new_size))
	font_str = font_str:gsub("h%d+$", "h" .. new_size)
	fonts[font_idx] = font_str

	-- 应用新字体
	vim.o.guifont = font_str
	vim.notify(font_str)
end

-- 显示主题和字体，切换字体代码中redraw不起作用
M.show_theme = function(flag)
	flag = flag or 0
	local info = ""

	if flag == 0 or flag == 1 then
		info = info .. " font: " .. vim.o.guifont .. "\n"
	end
	if flag == 0 or flag == 2 then
		info = info .. "theme: " .. vim.g.colors_name .. "\n"
	end

	if info ~= "" then
		-- 剔除字体名称中的_Nerd类似后缀
		info = string.gsub(info, "_[%w]+", "")
		-- 删除最后一个多余的换行符
		info = string.sub(info, 1, #info - 1)
		vim.notify(info)
	end
end

-- 切换字体及主题，并显示相关信息
M.switch_ui = function(flag)
	flag = flag or 0
	if flag == 0 or flag == 1 then
		M.switch_font()
	end
	if flag == 0 or flag == 2 then
		M.switch_theme()
	end

	if flag == 3 then
		M.change_font_size(1)
	end

	if flag == 4 then
		M.change_font_size(-1)
	end

	M.show_theme(flag)
end

-- 启动时随机选中主题和字体
M.switch_font()
M.switch_theme()
-- M.switch_ui(0)

return M
