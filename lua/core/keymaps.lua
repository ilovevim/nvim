local keymap = vim.keymap
-- 取消高亮
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- vim-highlighter插件映射，当nohlsearch时，高亮单词的前进后退，否则为?/搜索词的前进/后退
keymap.set("n", "n", "<cmd>call HiSearch('n')<CR>")
keymap.set("n", "N", "<cmd>call HiSearch('N')<CR>")

-- 小技巧：显示当前位置所属函数名，原理是往回匹配顶格字符（即无空格或tab前缀）
-- keymap.set("n", "<c-g>", "<cmd>echo getline(search('\\v^[[:alpha:]$_]', 'bn', 1, 100))<CR>", { desc = "outer scope" })

-- 诊断相关映射，[d和]d已经被默认映射了，此处重新映射是为了跳转后显示诊断浮窗（float=true）
keymap.set("n", "<leader>dd", vim.diagnostic.setloclist, { desc = "diag: [d]ocument" })
keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "diag: prev" })
keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "diag: next" })
keymap.set("n", "<leader>dl", function()
	vim.diagnostic.open_float()
end, { desc = "diag: [l]ine" })
keymap.set("n", "<leader>de", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "diag: [e]nable" })

-- 诊断跳转键默认已映射到[d和]d（vim/_defaults.lua）
-- keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "diag: [p]rev" })
-- keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "diag: [n]ext" })

-- 模式切换，jk在visual模式下容易被触发取消区域选择
-- keymap.set("i", "jk", "<ESC>")

-- 多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- 注释，支持[count]gcc
keymap.set("n", "<c-cr>", "gcc", { remap = true })
keymap.set("i", "<c-cr>", "<esc>gcc", { remap = true })

-- 若干快捷方式
vim.keymap.set({ "n", "v" }, "<tab>", "%") -- 括号间跳转

-- 快速调整窗口大小
vim.keymap.set("n", "<C-Left>", "<C-w><")
vim.keymap.set("n", "<C-Right>", "<C-w>>")
vim.keymap.set("n", "<C-Up>", "<C-w>+")
vim.keymap.set("n", "<C-Down>", "<C-w>-")

-- 窗口
-- keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
-- keymap.set("n", "<leader>sh", "<C-w>s") -- 垂直新增窗口
keymap.set("n", "<c-c>", "<C-w>c") -- 关闭窗口

-- 跳转到当前文件所属目录
-- keymap.set("n", "<A-j>", ':<c-r>=winnr()<cr>windo cd <c-r>=expand("%:p:h")<cr>')
keymap.set("n", "<A-j>", ':cd <c-r>=expand("%:p:h")<cr>')
keymap.set("n", "<A-e>", ':e <c-r>=expand("%:p:h")<cr>\\')

-- 保存文件
keymap.set("n", "<leader>bs", "<cmd>update<cr>", { desc = "buffer: [s]ave" })
keymap.set("i", "<leader>bs", "<esc><cmd>update<cr>", { desc = "buffer: [s]ave" })

-- Lazy Sync同步插件
keymap.set("n", "<leader>pl", "<cmd>Lazy sync<cr>", { desc = "plugin: [l]azy sync" })
keymap.set("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "plugin: [m]ason" })

-- ---------- 插件 ---------- ---
-- nvim-tree
-- keymap.set("n", "<F1>", "<cmd>NvimTreeFindFileToggle!<CR>")
-- keymap.set("n", "<S-F1>", "<cmd>NvimTreeFindFile!<CR>")
-- keymap.set("n", "<F1><F1>", ":NvimTreeClose<CR>")

-- 代码大纲（函数列表）
-- keymap.set("n", "<F2>", ":Vista<CR>")
-- keymap.set("n", "<F2>", "<cmd>AerialToggle!<CR>")

-- toggleterm插件快捷键
keymap.set("n", "<F3>", "<cmd>silent up | lua require('plug.toggleterm').run_buffer()<cr>", { desc = "run file" })
keymap.set("i", "<F3>", "<esc><cmd>silent up | lua require('plug.toggleterm').run_buffer()<cr>", { desc = "run file" })
keymap.set("n", "<C-F3>", "<cmd>silent up | lua require('plug.toggleterm').run_project()<cr>", { desc = "run project" })
keymap.set(
	"i",
	"<C-F3>",
	"<esc><cmd>silent up | lua require('plug.toggleterm').run_project()<cr>",
	{ desc = "run project" }
)

-- 循环切换颜色主题、字体大小
keymap.set("n", "<F12>", "<Cmd>lua require('core.themes').show_theme(0)<cr>", { desc = "show font and theme" })
keymap.set("n", "<S-F12>", "<Cmd>lua require('core.themes').switch_ui(0)<cr>", { desc = "switch font and theme" })
keymap.set("n", "<C-F12>", "<Cmd>lua require('core.themes').switch_ui(1)<cr>", { desc = "switch font" })
keymap.set("n", "<A-F12>", "<Cmd>lua require('core.themes').switch_ui(2)<cr>", { desc = "switch theme" })
keymap.set("n", "<C-F11>", "<Cmd>lua require('core.themes').switch_ui(3)<cr>", { desc = "increase font size" })
keymap.set("n", "<A-F11>", "<Cmd>lua require('core.themes').switch_ui(4)<cr>", { desc = "decrease font size" })

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
		vim.hl.on_yank()
	end,
})

----------------------------------------
-- dapui插件（表达式求值）
----------------------------------------
vim.keymap.set({ "n", "v" }, "<a-k>", "<cmd>lua require('dapui').eval()<CR>")

----------------------------------------
-- inc-rename插件预览式更名，替换vim.lsp.buf.rename
----------------------------------------
-- vim.keymap.set("n", "<leader>cr", function()
-- 	return ":IncRename " .. vim.fn.expand("<cword>")
-- end, { expr = true, desc = "code: [r]ename" })

----------------------------------------
-- Cybu.nvim插件切换buffer
----------------------------------------
-- vim.keymap.set("n", "<A-h>", "<Plug>(CybuPrev)")
-- vim.keymap.set("n", "<A-l>", "<Plug>(CybuNext)")
-- vim.keymap.set({ "n", "v" }, "<c-s-tab>", "<plug>(CybuLastusedPrev)")
-- vim.keymap.set({ "n", "v" }, "<c-tab>", "<plug>(CybuLastusedNext)")

----------------------------------------
-- mini.nvim插件
----------------------------------------
keymap.set("n", "<leader>wf", "<cmd>lua MiniFiles.open()<cr>", { desc = "mini: [f]ile" })
-- keymap.set("n", "<A-h>", "<cmd>lua MiniBracketed.buffer('backward')<cr>")
-- keymap.set("n", "<A-l>", "<cmd>lua MiniBracketed.buffer('forward')<cr>")

----------------------------------------
-- buffer管理
----------------------------------------
-- keymap.set("n", "<A-l>", "<cmd>bnext<CR>")
-- keymap.set("n", "<A-h>", "<cmd>bprevious<CR>")
-- keymap.set("n", "<A-d>", "<cmd>bdelete<CR>")

----------------------------------------
-- bufferline插件
----------------------------------------
-- keymap.set("n", "<A-h>", ":BufferLineCyclePrev<CR>")
-- keymap.set("n", "<A-l>", ":BufferLineCycleNext<CR>")

----------------------------------------
-- Neogen插件（生成代码注释模板）
----------------------------------------
keymap.set("n", "<leader>cf", "<cmd>Neogen func<cr>", { desc = "comment: [f]unc" })
keymap.set("n", "<leader>cF", "<cmd>Neogen file<cr>", { desc = "comment: [F]ile" })
keymap.set("n", "<leader>cC", "<cmd>Neogen class<cr>", { desc = "comment: [C]lass" })
keymap.set("n", "<leader>cT", "<cmd>Neogen type<cr>", { desc = "comment: [T]ype" })

----------------------------------------
-- barbar.nvim插件
----------------------------------------
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map("n", "<A-,>", "<Cmd>BufferPrevious<CR>", opts)
map("n", "<A-.>", "<Cmd>BufferNext<CR>", opts)

-- Re-order to previous/next
map("n", "<A-<>", "<Cmd>BufferMovePrevious<CR>", opts)
map("n", "<A->>", "<Cmd>BufferMoveNext<CR>", opts)

-- Goto buffer in position...
map("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", opts)
map("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", opts)
map("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", opts)
map("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", opts)
map("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", opts)
map("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", opts)
map("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", opts)
map("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", opts)
map("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", opts)
map("n", "<A-0>", "<Cmd>BufferLast<CR>", opts)

-- Pin/unpin buffer
map("n", "<A-p>", "<Cmd>BufferPin<CR>", opts)

-- Goto pinned/unpinned buffer
--                 :BufferGotoPinned
--                 :BufferGotoUnpinned

-- Close buffer
map("n", "<A-c>", "<Cmd>BufferClose<CR>", opts)

-- Wipeout buffer
--                 :BufferWipeout

-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight

-- Magic buffer-picking mode
map("n", "<C-p>", "<Cmd>BufferPick<CR>", opts)
map("n", "<C-s-p>", "<Cmd>BufferPickDelete<CR>", opts)

-- Sort automatically by...
map("n", "<Space>bb", "<Cmd>BufferOrderByBufferNumber<CR>", opts)
map("n", "<Space>bn", "<Cmd>BufferOrderByName<CR>", opts)
map("n", "<Space>bd", "<Cmd>BufferOrderByDirectory<CR>", opts)
map("n", "<Space>bl", "<Cmd>BufferOrderByLanguage<CR>", opts)
map("n", "<Space>bw", "<Cmd>BufferOrderByWindowNumber<CR>", opts)

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used
