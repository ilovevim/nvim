local keymap = vim.keymap
local opt = { noremap = true, silent = true }

-- 取消高亮
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- vim-highlighter插件映射，当nohlsearch时，高亮单词的前进后退，否则为?/搜索词的前进/后退
keymap.set("n", "n", "<cmd>call HiSearch('n')<CR>")
keymap.set("n", "N", "<cmd>call HiSearch('N')<CR>")

-- 小技巧：显示当前位置所属函数名，原理是往回匹配顶格字符（即无空格或tab前缀）
-- keymap.set("n", "<c-g>", "<cmd>echo getline(search('\\v^[[:alpha:]$_]', 'bn', 1, 100))<CR>", { desc = "outer scope" })
-- Diagnostic keymaps，[d、]d按键已经默认配置诊断上下跳转
keymap.set("n", "<leader>dd", vim.diagnostic.setloclist, { desc = "diag: [d]ocument" })
keymap.set("n", "<leader>di", function()
	vim.diagnostic.open_float({ header = "", scope = "line" })
end, { desc = "diag: [i]nfo" })

-- 诊断跳转键默认已映射到[d和]d（vim/_defaults.lua）
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "diag: [p]rev" })
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "diag: [n]ext" })

-- 模式切换，jk在visual模式下容易被触发取消区域选择
-- keymap.set("i", "jk", "<ESC>")

-- 多行移动
-- keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- 注释，支持[count]gcc
keymap.set("n", "<c-cr>", "gcc", { remap = true })
keymap.set("i", "<c-cr>", "<esc>gcc", { remap = true })

-- 窗口
-- keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
-- keymap.set("n", "<leader>sh", "<C-w>s") -- 垂直新增窗口
keymap.set("n", "<c-c>", "<C-w>c") -- 关闭窗口

-- 跳转到当前文件所属目录
-- keymap.set("n", "<A-j>", ':<c-r>=winnr()<cr>windo cd <c-r>=expand("%:p:h")<cr>')
keymap.set("n", "<A-j>", ':cd <c-r>=expand("%:p:h")<cr>')

-- 保存文件
keymap.set("n", "\\w", "<cmd>update<cr>", { desc = "buffer update" })
keymap.set("i", "\\w", "<esc><cmd>update<cr>", { desc = "buffer update" })

-- ---------- 插件 ---------- ---
-- nvim-tree
keymap.set("n", "<F1>", "<cmd>NvimTreeFindFileToggle!<CR>")
keymap.set("n", "<S-F1>", "<cmd>NvimTreeFindFile!<CR>")
-- keymap.set("n", "<F1><F1>", ":NvimTreeClose<CR>")

-- 代码大纲（函数列表）
-- keymap.set("n", "<F2>", ":Vista<CR>")
-- keymap.set("n", "<F2>", "<cmd>AerialToggle!<CR>")

-- mini.nvim
keymap.set("n", "<leader>wm", "<cmd>lua MiniFiles.open()<cr>", { desc = "workspace: [m]ini.file" })
-- keymap.set("n", "<A-h>", "<cmd>lua MiniBracketed.buffer('backward')<cr>")
-- keymap.set("n", "<A-l>", "<cmd>lua MiniBracketed.buffer('forward')<cr>")

-- buffer管理
keymap.set("n", "<A-l>", "<cmd>bnext<CR>")
keymap.set("n", "<A-h>", "<cmd>bprevious<CR>")
keymap.set("n", "<A-d>", "<cmd>bdelete<CR>")

-- bufferline插件
-- keymap.set("n", "<A-h>", ":BufferLineCyclePrev<CR>")
-- keymap.set("n", "<A-l>", ":BufferLineCycleNext<CR>")

-- toggleterm插件快捷键
keymap.set("n", "<F3>", "<cmd>silent up | lua require('plug.toggleterm').run_file()<cr>", { desc = "run file" })
keymap.set("i", "<F3>", "<esc><cmd>silent up | lua require('plug.toggleterm').run_file()<cr>", { desc = "run file" })

-- 循环切换颜色主题
keymap.set("n", "<F12>", "<Cmd>lua require('core.themes').show_theme(0)<cr>", { desc = "show font and theme" })
keymap.set("n", "<S-F12>", "<Cmd>lua require('core.themes').switch_ui(0)<cr>", { desc = "switch font and theme" })
keymap.set("n", "<C-F12>", "<Cmd>lua require('core.themes').switch_ui(1)<cr>", { desc = "switch font" })
keymap.set("n", "<A-F12>", "<Cmd>lua require('core.themes').switch_ui(2)<cr>", { desc = "switch theme" })

-- neovim-session-manager
-- keymap.set("n", "<leader>wo", "<cmd>SessionManager load_session<CR>", { desc = "[o]pen session" })
-- keymap.set("n", "<leader>ws", "<cmd>SessionManager save_current_session<CR>", { desc = "[s]ave session" })
-- keymap.set("n", "<leader>wd", "<cmd>SessionManager delete_session<CR>", { desc = "[d]elete session" })

-- treesitter-context，跳到下一个节点（与aerial及相关lsp的类/函数跳转功能重复）
-- keymap.set("n", "[c", function()
-- 	require("treesitter-context").go_to_context(vim.v.count1)
-- end, { silent = true })

-- 终端模式键映射https://zhuanlan.zhihu.com/p/559747798
function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "exit terminal mode" })
	-- vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
	vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
	vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
	vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
	vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- Highlight when yanking (copying) text
-- Try it with `yap` in normal mode. See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- dapui插件（表达式求值）
vim.keymap.set({ "n", "v" }, "<a-k>", "<cmd>lua require('dapui').eval()<CR>")
