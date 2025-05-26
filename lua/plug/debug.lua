---@diagnostic disable: missing-fields
-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return { -- NOTE: Yes, you can install new plugins here!
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	-- NOTE: And you can specify dependencies as well
	dependencies = {
		-- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",

		-- Required dependency for nvim-dap-ui
		"nvim-neotest/nvim-nio",

		-- Installs the debug adapters for you
		"mason-org/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- Add your own debuggers here
		-- "leoluz/nvim-dap-go",
		"mfussenegger/nvim-dap-python",
	},
	keys = {
		-- Basic debugging keymaps, feel free to change to your liking!
		{
			"<leader>ds",
			function()
				require("dap").continue()
			end,
			desc = "debug: [s]tart",
		},
		{
			"<leader>dT",
			function()
				require("dap").terminate()
			end,
			desc = "debug: [T]erminate",
		},
		{
			"<M-i>",
			function()
				require("dap").step_into()
			end,
			desc = "debug: step into",
		},
		{
			"<M-o>",
			function()
				require("dap").step_out()
			end,
			desc = "debug: step out",
		},
		{
			"<M-n>",
			function()
				require("dap").step_over()
			end,
			desc = "debug: step over",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "debug: [b]reak",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("breakpoint condition: "))
			end,
			desc = "debug: [B]reak cond",
		},
		-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
		{
			"<leader>dt",
			function()
				require("dapui").toggle()
			end,
			desc = "debug: [t]oggle ",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				-- "delve",
				"debugpy",
				"java-debug-adapter",
			},
		})

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			-- Set icons to characters that are more likely to work in every terminal.
			--    Feel free to remove or use ones that you like more! :)
			--    Don't feel like these are good choices.
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
		})

		-- 不切换到dapui多个调试窗口，保持在源代码窗口
		-- dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		--[[ -- Install golang specific config
        require("dap-go").setup({
            delve = {
                -- On Windows delve must be run attached or it crashes.
                -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
                detached = vim.fn.has("win32") == 0,
            },
        }) ]]

		-- debug虚拟文本设置，默认inline会影响debug状态下的代码阅读，改为结尾注释形式
		require("nvim-dap-virtual-text").setup({ commented = true, virt_text_pos = "eol" })

		-- python调试客户端
		local dap_python = require("dap-python")

		local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
		-- local debugpy_path = mason_path .. "packages/debugpy/venv/Scripts/python"
		local debugpy_path = "python"
		dap_python.setup(debugpy_path)
		-- Debug adapter didn't respond. Either the adapter is slow ...
		-- https://github.com/mfussenegger/nvim-dap/discussions/846
		-- dap_python.default_port = 38000

		-- dap.configurations.python = {
		-- 	{
		-- 		type = "python",
		-- 		request = "launch",
		-- 		name = "Launch file",
		-- 		program = "${file}",
		-- 		pythonPath = "python",
		-- cwd = function()
		-- 	-j https://github.com/mfussenegger/nvim-dap/discussions/919
		-- 	-- util.root_pattern("pyproject.toml")(vim.fn.getcwd())
		-- 	return vim.fn.getcwd()
		-- end,
		--
		-- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
		-- 		env = { PYTHONPATH = vim.fn.getcwd() },
		-- 	},
		-- }

		-- Java adapter、configuration无需额外配置，jdtls+java-debug已经绑定自动处理了
	end,
}
