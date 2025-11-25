-- 非neovide环境下，直接返回
if not vim.g.neovide then
	return
end

-- 前置重新刷新，解决偶尔有迟钝反应现象
vim.g.neovide_no_idle = true

-- 启动时关闭输入法，仅可输入英文
vim.g.neovide_input_ime = false

-- 切换全屏，直接let设置在noice插件下浮窗会出现频闪
-- vim.api.nvim_set_keymap("n", "<F11>", ":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>", {})
vim.keymap.set("n", "<F11>", function()
	vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { silent = true })

-- 输入法禁用开关：仅在insert/search模式下打开ime输入，其他关闭输入法
-- https://neovide.dev/configuration.html
local function set_ime(args)
	if args.event:match("Enter$") then
		vim.g.neovide_input_ime = true
	else
		vim.g.neovide_input_ime = false
	end
end

local ime_group = vim.api.nvim_create_augroup("set_ime", { clear = true })

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
	group = ime_group,
	pattern = "*",
	callback = set_ime,
})

vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
	group = ime_group,
	pattern = { ":", "/", "?" },
	-- pattern = "[/\\?]",
	callback = set_ime,
})
