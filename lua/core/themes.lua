-- 设置随机数种子（Neovim启动时执行一次）
math.randomseed(os.time())

-- 设置只有neovide才能支持的NerdFont（连字符等），在themes.lua中切换
-- "VictorMono_NFM:霞鹜文楷等宽:h10", -- 字体太细
-- "AnonymicePro_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- 英文字体显小，中文字体对比过大
-- "UbuntuMono_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- Ubuntu系统专用字体，英文字体太小
-- "Inconsolata_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- 英文字体显小，中文字体对比过大
-- "SpaceMono_Nerd_Font:h12", -- 行间距较大
-- "SF_Mono:h12" -- 字体加载报错
-- 以下字体共有问题：Aerial大纲插件中类、函数图标显示异常
-- "Monoisome:h12",
-- "MonacoLigaturized:h12",
-- "Sarasa_Nerd:h12", -- 同名：等距更纱黑体_SC:h12
-- "Hasklig:h12" -- 从SourceCodePro衍生，增加连字符
-- "Noto_Sans_Mono_CJK_SC,等距更纱黑体_SC:h11",
-- "Monoid_Nerd_Font_Mono:h11", -- 老牌编程字体（英文大写比小写大太多）
local fonts = {
	"SauceCodePro_NFM,等距更纱黑体_SC:h11", -- 英文字体显小，显得中文字体过大
	"JetBrainsMono_NF,等距更纱黑体_SC:h11",
	"FiraCode_Nerd_Font,等距更纱黑体_SC:h11",
	"Hack_Nerd_Font_Mono,霞鹜文楷等宽:h11",
	"CasCadia_Code_NF,霞鹜文楷等宽:h11",
	"CommitMono_Nerd_Font,等距更纱黑体_SC:h11", -- 以Fira Code和JetBrains Mono为灵感制作
	"RobotoMono_Nerd_Font_Mono,等距更纱黑体_SC:h11",
	"MesloLGMDZ_Nerd_Font_Mono,等距更纱黑体_SC:h11", -- 苹果专用开发者字体（Line Gap, Medium, Dotted zero）
	"BlexMono_Nerd_Font_Mono,霞鹜文楷等宽:h11", -- IBM出品
	"GeistMono_NFM,霞鹜文楷等宽:h11",
	"Hurmit_Nerd_Font_Mono,霞鹜文楷等宽:h11", -- 专为编码设计
	"Maple_Mono_Normal_NF_CN:h11",
	"CodeNewRoman_Nerd_Font_Mono,霞鹜文楷等宽:h12",
	"FantasqueSansM_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- 英文字体显小，中文字体对比过大
	"Iosevka_NFM,霞鹜文楷等宽:h12", -- 中文版即为Sarasa（等距更纱黑体）
	"EnvyCodeR_Nerd_Font_Mono,霞鹜文楷等宽:h12",
}

-- 自选颜色得到主题
-- "molokai", "neosolarized", "ayu",
local themes = {
	"tokyonight",
	"gruvbox-material",
	"catppuccin",
	"kanagawa",
	"hybrid",
	"sonokai",
	"onedark",
	"everforest",
	"nightfox",
	"rose-pine",
	"vscode",
	"github_dark_dimmed",
	"jellybeans",
	"PaperColor",
	"monokai-pro",
	"one",
	"oxocarbon",
	"onenord",
	"miasma",
	"OceanicNext",
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

	M.show_theme(flag)
end

-- 启动时随机选中主题和字体
M.switch_font()
M.switch_theme()
-- M.switch_ui(0)

return M
