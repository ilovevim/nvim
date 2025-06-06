vim.opt.termguicolors = true

require("bufferline").setup({
	options = {
		-- mode = "tabs",
		-- 使用 nvim 内置lsp
		diagnostics = "nvim_lsp",
		-- 左侧让出 nvim-tree 的位置
		--     offsets = {{
		--         filetype = "NvimTree",
		--         text = "FileExplorer",
		--         highlight = "Directory",
		--         text_align = "left",
		--         separtor = "true"
		--     }}
		--
	},
})
