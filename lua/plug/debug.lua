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
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- Add your own debuggers here
		-- "leoluz/nvim-dap-go",
		"mfussenegger/nvim-dap-python",
	},
	keys = function(_, keys)
		local dap = require("dap")
		local dapui = require("dapui")
		return {
			-- Basic debugging keymaps, feel free to change to your liking!
			{ "<F5>", dap.continue, desc = "debug: start/continue" },
			{ "<F6>", dap.step_into, desc = "debug: step into" },
			{ "<F7>", dap.step_over, desc = "debug: step over" },
			{ "<C-F6>", dap.step_out, desc = "debug: step out" },
			{ "<leader>cb", dap.toggle_breakpoint, desc = "debug: [b]reak toggle" },
			{
				"<leader>cB",
				function()
					dap.set_breakpoint(vim.fn.input("breakpoint condition: "))
				end,
				desc = "debug: [B]reak set",
			},
			-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
			{ "<F8>", dapui.toggle, desc = "debug: last session result" },
			unpack(keys),
		}
	end,
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

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
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

		-- debug虚拟文本
		require("nvim-dap-virtual-text").setup()

		-- python调试客户端
		require("dap-python").setup("python")

		-- dap.configurations.python = {
		-- 	{
		-- 		type = "python",
		-- 		request = "launch",
		-- 		name = "Launch file",
		-- 		program = "${file}",
		-- pythonPath = "python",
		-- cwd = function()
		-- 	-- https://github.com/mfussenegger/nvim-dap/discussions/919
		-- 	-- util.root_pattern("pyproject.toml")(vim.fn.getcwd())
		-- 	return vim.fn.getcwd()
		-- end,
		--
		-- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
		-- 	env = { PYTHONPATH = vim.fn.getcwd() },
		-- },
		-- }
	end,
}
