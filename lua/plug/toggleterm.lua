-- 参考https://blog.csdn.net/qq_41437512/article/details/127361967
-- vim.o.termguicolors = true
-- vim.cmd[[ autocmd TermOpen term://* lua require('toggleterm').toggle() ]]

--考虑根据不同文件类型进行分类设置，暂时只适用于python（支持pytest）
-- vim.g.run_cmd_args = "-m pytest"
vim.g.run_cmd_args = ""

-- 来自大模型生成代码
local function find_files_by_patterns(root_dir, patterns)
	local found_files = {}
	local handle
	local entries

	-- 使用vim.loop.fs_scandir递归遍历目录
	local function scan_dir(current_dir)
		handle, entries = vim.uv.fs_scandir(current_dir)
		if not handle then
			return
		end

		while true do
			local name, type = vim.uv.fs_scandir_next(handle)
			if not name then
				break
			end

			local full_path = current_dir .. "/" .. name

			if type == "directory" then
				-- 跳过常见的隐藏目录（如.git, node_modules等），提升遍历效率
				if not name:match("^%.") and name ~= "node_modules" then
					-- scan_dir(full_path)
				end
			elseif type == "file" then
				-- 检查文件是否匹配任一模式
				for _, pattern in ipairs(patterns) do
					if name:match(pattern) then
						table.insert(found_files, full_path)
						break -- 匹配一个模式即可，无需检查其他模式
					end
				end
			end
		end
	end

	scan_dir(root_dir)
	return found_files
end

local M = {}

--- 运行当前缓冲区文件
M.run_buffer = function()
	-- 当前缓冲区文件名
	local filetype = vim.bo.filetype
	local filename = vim.api.nvim_buf_get_name(0)
	M.run_file(filename, filetype)
end

--- 运行当前项目（基于当前缓冲区文件类型确定项目类型，比如python或java项目）
M.run_project = function()
	local filetype = vim.bo.filetype
	local filename = M.detect_mainfile(filetype)

	if filename then
		M.run_file(filename, filetype)
	end
end

M.detect_mainfile = function(filetype)
	-- 当前工作目录
	local root_dir = vim.uv.cwd()

	local patterns = {}
	if filetype == "python" then
		patterns = { "main%.py$", "app%.py$" }
	elseif filetype == "java" then
		patterns = { "Main%.java$", ".*Application%.java$" }
	else
		return nil
	end

	local matches = find_files_by_patterns(root_dir, patterns)
	if matches and #matches > 0 then
		return matches[1] -- 返回第一个匹配的文件
	else
		vim.notify(table.concat(patterns, " | ") .. " not found!")
	end
	return nil
end

-- 运行Python、java文件
-- vim.api.nvim_set_keymap('n', '<leader>r', ":w<CR>:terminal python %<CR>", {noremap = true, silent = true})
-- https://www.showapi.com/news/article/66b932394ddd79f11a2b9f36
M.run_file = function(filename, filetype)
	-- 当前buffer文件名
	-- local filename = vim.api.nvim_buf_get_name(0)

	-- 当前工作目录
	local cwd = vim.uv.cwd()
	-- 文件路径改为相对路径，即替换cwd部分为'.'
	filename = string.gsub(filename, cwd, ".")

	local cmd = ""
	-- 基于文件类型，指定执行程序
	-- local filetype = vim.bo.filetype
	if filetype == "python" then
		cmd = "python " .. filename
		-- 以test开头或结尾的文件，启用pytest
		if string.match(filename, "[/\\]*test_.+py$") ~= nil or string.match(filename, "[/\\]*.+_test.py$") ~= nil then
			cmd = "python " .. vim.g.run_cmd_args .. " " .. filename
		end
	elseif filetype == "java" then
		cmd = "java " .. filename
	end

	local Terminal = require("toggleterm.terminal").Terminal
	if cmd ~= "" then
		-- direction支持horizontal、vertical、float、tab
		direction = "vertical"

		-- 如果竖屏则切换为水平方向堆叠（宽高比经验值2区分）
		if (vim.o.columns / vim.o.lines) < 2 then
			direction = "horizontal"
		end

		-- print(vim.o.columns, vim.o.lines, vim.o.columns / vim.o.lines, direction)

		-- 环境变量env，给PYTHONPATH指定当前工作目录，避免python程序时报ModuleNotFound错误
		local term = Terminal:new({
			cmd = cmd,
			hidden = false,
			start_in_insert = false,
			direction = direction,
			close_on_exit = false,
			auto_scroll = false,
			env = { PYTHONPATH = cwd },
		})
		term:open()
	else
		print("run: unsupported filetype " .. filetype .. "!")
	end
end

return M
