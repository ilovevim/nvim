-- 若不确定字体名称，可执行set guifont=*查看全部可用的字体名称
-- 设置只有neovide才能支持的NerdFont（连字符等），在themes.lua中切换
-- "SpaceMono_Nerd_Font:h12", -- 行间距较大
-- "AnonymicePro_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- 英文字体显小，中文字体对比过大
-- "Inconsolata_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- 英文字体显小，中文字体对比过大

-- 以下字体共有问题：Aerial大纲插件中类、函数图标显示异常
-- 可通过fallback到Symbols_Nerd_Font纯图标字体来解决
-- "Monoisome:h12",
-- "MonacoLigaturized:h12",
-- "Sarasa_Nerd:h12", -- 同名：等距更纱黑体_SC:h12
-- "Hasklig:h12" -- 从SourceCodePro衍生，增加连字符
-- "LXGW_Bright_Code:h13", -- Monospace+霞鹜文楷等宽合成字体
local fonts = {
	"BlexMono_Nerd_Font_Mono,霞鹜文楷等宽:h12", -- IBM出品
	"CaskaydiaCove_NFM,Source_Han_Sans_SC:h12",
	"CodeNewRoman_Nerd_Font_Mono,霞鹜文楷等宽:h13",
	"CommitMono_Nerd_Font,等距更纱黑体_SC:h12", -- 以Fira Code和JetBrains Mono为灵感制作nvi
	"DejaVuSansM_Nerd_Font_Mono,霞鹜文楷等宽:h12",
	"EnvyCodeR_Nerd_Font_Mono,霞鹜文楷等宽:h12",
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
	"Monoid_Nerd_Font_Mono,微软雅黑:h11", -- 老牌编程字体（英文大写比小写大太多）
	"Mononoki_Nerd_Font_Mono,霞鹜文楷等宽:h13",
	"NotoSansM_NFM,微软雅黑:h12",
	"Noto_Sans_Mono_CJK_SC,Symbols_Nerd_Font:h12",
	"RecMonoLinear_Nerd_Font_Mono,霞鹜文楷等宽:h12",
	"RobotoMono_Nerd_Font_Mono,等距更纱黑体_SC:h12",
	"SauceCodePro_NFM,等距更纱黑体_SC:h12", -- 英文字体显小，显得中文字体过大
	"SFMono_Nerd_Font,Symbols_Nerd_Font:h12",
	"UbuntuMono_Nerd_Font_Mono,霞鹜文楷等宽:h13", -- Ubuntu系统专用字体，英文字体太小
	"VictorMono_NFM,霞鹜文楷等宽:h12", -- 字体太细
	"YaHei_Consolas_Hybrid,Symbols_Nerd_Font:h12", -- 微软雅黑+Consolas混合字体（同时支持中英文）
	"YaHei_Monaco_Hybird,Symbols_Nerd_Font:h12",
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
	"posterpole",
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
	step = step or 1 -- 设置默认值
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
M.show_style = function()
	-- 剔除字体名称中的_Nerd类似后缀
	local info = vim.g.colors_name .. " | " .. string.gsub(vim.o.guifont, "_[%w]+", "")
	vim.notify(info)
end

-- 切换字体及主题，并显示相关信息
M.switch_style = function(flag)
	local actions = {
		[1] = M.switch_theme,
		[2] = M.switch_font,
		[3] = M.change_font_size,
		[4] = function()
			M.change_font_size(-1)
		end,
	}
	if flag >= 1 and flag <= 4 then
		actions[flag]()
		M.show_style()
	end
end

M.set_style = function()
	local options = {
		{ desc = "switch theme", value = 1 },
		{ desc = "switch font", value = 2 },
		{ desc = "increase font size", value = 3 },
		{ desc = "decrease font size", value = 4 },
	}

	vim.ui.select(options, {
		prompt = vim.g.colors_name .. " | " .. string.gsub(vim.o.guifont, "_[%w]+", ""),
		format_item = function(item)
			return item.desc
		end,
	}, function(choice)
		if choice then
			M.switch_style(choice.value)
		end
	end)
end

-- 启动时打乱表格顺序，随机切换效果
math.randomseed(os.time())
shuffle_table(fonts)
shuffle_table(themes)

-- 启动时随机选中主题和字体
M.switch_theme()
M.switch_font()

return M
