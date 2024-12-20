-- 参考https://blog.csdn.net/qq_41437512/article/details/127361967
-- vim.o.termguicolors = true
-- vim.cmd[[ autocmd TermOpen term://* lua require('toggleterm').toggle() ]]

local M = {}

-- 运行Python、java文件
-- vim.api.nvim_set_keymap('n', '<leader>r', ":w<CR>:terminal python %<CR>", {noremap = true, silent = true})
-- https://www.showapi.com/news/article/66b932394ddd79f11a2b9f36
M.run_by_ft = function()
	-- 当前buffer文件名
	local filename = vim.api.nvim_buf_get_name(0)
	-- 当前工作目录
	local cwd = vim.uv.cwd()
	-- 替换工作目录前缀为'.'
	filename = "." .. string.gsub(filename, cwd, "")

	local cmd = ""
	-- 基于文件类型，指定执行程序
	local filetype = vim.bo.filetype
	if filetype == "python" then
		cmd = "python " .. filename
	elseif filetype == "java" then
		cmd = "java " .. filename
	end

	local Terminal = require("toggleterm.terminal").Terminal
	if cmd ~= "" then
		-- print(cmd)
		-- 环境变量env，给PYTHONPATH指定当前工作目录，避免python程序时报ModuleNotFound错误
		-- direction支持horizontal、vertical、float、tab
		local term = Terminal:new({
			cmd = cmd,
			hidden = false,
			start_in_insert = false,
			direction = "horizontal",
			close_on_exit = false,
			auto_scroll = false,
			env = { PYTHONPATH = cwd },
		})
		term:open()
	else
		print("run: unsupported filetype!")
	end
end

return M
