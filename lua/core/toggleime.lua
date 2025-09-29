-- 本文件只针对neovide生效
if not vim.g.neovide then
	return
end

-- 前置重新刷新，解决偶尔有迟钝反应现象
vim.g.neovide_no_idle = true

-- 启动时关闭输入法，以便于输入英文命令
vim.g.neovide_input_ime = false

-- 切换全屏
vim.api.nvim_set_keymap("n", "<F11>", ":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>", {})

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
	callback = set_ime,
})
