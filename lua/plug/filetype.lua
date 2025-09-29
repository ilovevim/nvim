-- 基于扩展名识别http类型，供kulala.nvim插件正常使用
-- vim.filetype.add({
-- 	extension = {
-- 		["http"] = "http",
-- 	},
-- })

-- 创建自动命令组（防止重复注册）
local filetype_group = vim.api.nvim_create_augroup("filetype_group", { clear = true })

--- json格式化（rest.nvim插件）
vim.api.nvim_create_autocmd("FileType", {
	pattern = "json",
	group = filetype_group,
	callback = function(ev)
		-- vim.bo[ev.buf].formatexpr = ""
		vim.bo[ev.buf].formatprg = "jq"
	end,
})

-- http文件配置（rest.nvim插件）
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "http",
-- 	group = filetype_group,
-- 	callback = function(ev)
-- 		-- 定义 buffer-local 键位映射
-- 		-- rest.nvim插件
-- 		-- vim.keymap.set("n", "<leader>rr", "<cmd>Rest run<CR>", { buffer = ev.buf, desc = "rest: [r]un" })
--
-- 		-- kulala.nvim
-- 		vim.keymap.set("n", "<leader>rr", function()
-- 			require("kulala").run()
-- 		end, { buffer = ev.buf, desc = "rest: [r]un" })
-- 	end,
-- })

-- python文件配置
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	group = filetype_group,
	callback = function(ev)
		-- 定义 buffer-local 键位映射
		-- vim.keymap.set("n", "<leader>ci", function()
		-- 	require("lspimport").import()
		-- end, { buffer = ev.buf, desc = "code: [i]mport" })

		-- 切换公共/私有函数，junit中私有函数不会被执行
		vim.keymap.set("n", "<S-CR>", function()
			local line = vim.api.nvim_get_current_line()
			local line_ = line

			-- 函数名前增加或删除下划线
			if line:match("^%s*def%s+_(%w+)") then
				line_ = line:gsub("(%s*)def%s+_(%w+)", "%1def %2")
			else
				line_ = line:gsub("(%s*)def%s+(%w+)", "%1def _%2")
			end

			-- 替换当前行
			if line_ ~= line then
				vim.api.nvim_set_current_line(line_)
			end
		end, { buffer = ev.buf, desc = "toggle public/private function" })
	end,
})
