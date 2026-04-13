-- 20241030 luocm 整合kickstart配置脚本，清理部分插件（lspsaga、trouble、none-ls、lualine等）
-- 20241101 luocm 清除nvim-surround，用mini.surround代替
-- 20241101 luocm telescope中增加delete_buffer按键映射
-- 20241111 luocm python lsp：pyright、pylyzer不支持stub，使用jedi但最终换回pyright+ruff
-- 前缀键
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 是否有nerd字体()
vim.g.have_nerd_font = true

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- 插件配置
local plugins = {
	{ -- Detect tabstop and shiftwidth automatically
		"NMAC427/guess-indent.nvim",
		config = function()
			require("guess-indent").setup({})
		end,
	},
	-- { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },
	{ -- bufferline、lualine可mini相关套件替换
		"nvim-lualine/lualine.nvim",
		-- event = "VeryLazy",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
		config = function()
			require("lualine").setup({
				options = {
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = {
						{
							"mode",
							fmt = function(str)
								return str:sub(1, 1)
							end,
						},
					},
					-- 状态栏c段显示navic代码导航信息，此处基于官方配置进行了改写
					lualine_c = {
						"filename",
						{ -- navic代码导航
							"navic",
							-- Component specific options
							color_correction = nil, -- Can be nil, "static" or "dynamic". This option is useful only when you have highlights enabled.
							-- Many colorschemes don't define same backgroud for nvim-navic as their lualine statusline backgroud.
							-- Setting it to "static" will perform a adjustment once when the component is being setup. This should
							--   be enough when the lualine section isn't changing colors based on the mode.
							-- Setting it to "dynamic" will keep updating the highlights according to the current modes colors for
							--   the current section.

							navic_opts = nil, -- lua table with same format as setup's option. All options except "lsp" options take effect when set here.
						},
					},
					lualine_x = { -- 去掉'fileformat'（目前只有windows、linux图标）
						{ -- 宏录制状态提示：recording @q
							require("noice").api.status.mode.get,
							cond = require("noice").api.status.mode.has,
							color = { fg = "#ff9e64" },
						},
						-- {
						-- 	function()
						-- 		-- Check if MCPHub is loaded
						-- 		if not vim.g.loaded_mcphub then
						-- 			return "󰐻 -"
						-- 		end
						--
						-- 		local count = vim.g.mcphub_servers_count or 0
						-- 		local status = vim.g.mcphub_status or "stopped"
						-- 		local executing = vim.g.mcphub_executing
						--
						-- 		-- Show "-" when stopped
						-- 		if status == "stopped" then
						-- 			return "󰐻 -"
						-- 		end
						--
						-- 		-- Show spinner when executing, starting, or restarting
						-- 		if executing or status == "starting" or status == "restarting" then
						-- 			local frames =
						-- 				{ "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
						-- 			local frame = math.floor(vim.loop.now() / 100) % #frames + 1
						-- 			return "󰐻 " .. frames[frame]
						-- 		end
						--
						-- 		return "󰐻 " .. count
						-- 	end,
						-- 	color = function()
						-- 		if not vim.g.loaded_mcphub then
						-- 			return { fg = "#6c7086" } -- Gray for not loaded
						-- 		end
						--
						-- 		local status = vim.g.mcphub_status or "stopped"
						-- 		if status == "ready" or status == "restarted" then
						-- 			return { fg = "#50fa7b" } -- Green for connected
						-- 		elseif status == "starting" or status == "restarting" then
						-- 			return { fg = "#ffb86c" } -- Orange for connecting
						-- 		else
						-- 			return { fg = "#ff5555" } -- Red for error/stopped
						-- 		end
						-- 	end,
						-- },
						"encoding",
						"filetype",
					},
				},
			})
		end,
	}, -- 状态栏

	-- { -- 文档树
	-- 	"nvim-tree/nvim-tree.lua",
	-- 	config = function()
	-- 		-- disable netrw
	-- 		vim.g.loaded_netrw = 1
	-- 		vim.g.loaded_netrwPlugin = 1
	--
	-- 		require("nvim-tree").setup({
	-- 			view = {
	-- 				width = 25,
	-- 			},
	-- 			filters = {
	-- 				custom = {
	-- 					"\\.git$",
	-- 					"\\.svn$",
	-- 					"\\.hg$",
	-- 					"__pycache__",
	-- 				},
	-- 			},
	-- 			-- update_focused_file = {
	-- 			-- 	enable = true,
	-- 			-- 	update_root = {
	-- 			-- 		enable = true,
	-- 			-- 	},
	-- 			-- },
	-- 		})
	-- 	end,
	-- },
	{
		"nvim-neo-tree/neo-tree.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		lazy = false,
		keys = {
			{ "<F1>", ":Neotree toggle reveal<CR>", desc = "NeoTree toggle", silent = true },
		},
		config = function()
			require("neo-tree").setup({
				filesystem = {
					window = {
						width = 25,
						mappings = {
							["<F1>"] = "close_window",
						},
					},
					filtered_items = {
						hide_by_name = {
							"__pycache__",
							"gmcache",
						},
					},
				},
			})
		end,
	},

	"nvim-tree/nvim-web-devicons", -- 文档树图标

	"christoomey/vim-tmux-navigator", -- 用ctl-hjkl来定位窗口

	-- "nvim-treesitter/nvim-treesitter-context", -- 当前上下文，改用navic等面包屑插件
	-- "nvim-treesitter/nvim-treesitter-textobjects", -- 有flash后作用不大！
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		-- version = "*",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		-- dependencies = {
		-- 	"nvim-treesitter/nvim-treesitter-textobjects", -- 有flash后作用不大！
		-- },
		config = function()
			local parsers = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"vim",
				"vimdoc",
			}
			require("nvim-treesitter").install(parsers)
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf, filetype = args.buf, args.match

					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end

					-- check if parser exists and load it
					if not vim.treesitter.language.add(language) then
						return
					end
					-- enables syntax highlighting and other treesitter features
					vim.treesitter.start(buf, language)

					-- enables treesitter based folds
					-- for more info on folds see `:help folds`
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo.foldmethod = "expr"

					-- enables treesitter based indentation
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	-- "p00f/nvim-ts-rainbow", -- 配合treesitter，不同括号颜色区分
	{
		"HiPhish/rainbow-delimiters.nvim",
		submodules = false, -- 解决安装报错test/bin无法clone
		config = function()
			require("rainbow-delimiters.setup").setup({})
		end,
	},
	-- {
	-- 	"andymass/vim-matchup",
	-- 	init = function()
	-- 		-- 禁用系统自带matchit插件
	-- 		vim.g.loaded_matchit = 1
	-- 		-- may set any options here (default "status")
	-- 		-- vim.g.matchup_matchparen_offscreen = { method = "popup" }
	-- 	end,
	-- },
	-- { -- 交换列表、函数中元素（用mini.operators中gx功能替换）
	-- 	"mizlan/iswap.nvim",
	-- 	event = "VeryLazy",
	-- },

	{
		"mason-org/mason.nvim",
		lazy = true,
		keys = {
			{ "<leader>mm", "<cmd>Mason<cr>", desc = "[m]ason" },
		},
	},
	{ -- Main LSP Configuration
		"neovim/nvim-lspconfig",
		-- event = "VeryLazy",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "mason-org/mason.nvim", opts = {} }, -- NOTE: Must be loaded before dependants
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ -- 进度提示
				"j-hui/fidget.nvim",
				opts = {
					notification = {
						-- 等价于vim.notify = require("fidget.notification").notify
						-- override_vim_notify = true,
					},
				},
			},

			-- Allows extra capabilities provided by blink.cmp
			-- "saghen/blink.cmp",
		},
		config = function()
			-- Brief aside: **What is LSP?**
			--
			-- LSP is an initialism you've probably heard, but might not understand what it is.
			--
			-- LSP stands for Language Server Protocol. It's a protocol that helps editors
			-- and language tooling communicate in a standardized fashion.
			--
			-- In general, you have a "server" which is some tool built to understand a particular
			-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
			-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
			-- processes that communicate with some "client" - in this case, Neovim!
			--
			-- LSP provides Neovim with features like:
			--  - Go to definition
			--  - Find references
			--  - Autocompletion
			--  - Symbol Search
			--  - and more!
			--
			-- Thus, Language Servers are external tools that must be installed separately from
			-- Neovim. This is where `mason` and related plugins come into play.
			--
			-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
			-- and elegantly composed help section, `:help lsp-vs-treesitter`

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n" -- desc = "LSP: " .. desc
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", require("telescope.builtin").lsp_definitions, "goto [d]efinition")

					-- grr/grn/gra/gri/gO等已在runtime\lua\vim\_defaults.lua中被默认定义
					-- Find references for the word under your cursor.
					map("grr", require("telescope.builtin").lsp_references, "goto [r]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gri", require("telescope.builtin").lsp_implementations, "goto [i]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("grt", require("telescope.builtin").lsp_type_definitions, "goto [t]ype definition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>sd", require("telescope.builtin").lsp_document_symbols, "symbol: [d]ocument")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map("<leader>sw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "symbol: [w]orkspace")

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					-- map("<leader>cr", vim.lsp.buf.rename, "code: [r]ename")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					-- map("<leader>ca", vim.lsp.buf.code_action, "code: [a]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "goto [D]eclaration")

					-- 光标所在词浮窗提示
					map("K", vim.lsp.buf.hover, "hover document")

					-- 光标所在词浮窗提示(imap <c-s>已在_defaults.lua中定义)
					map("<c-s>", vim.lsp.buf.signature_help, "signature help")

					-- 工作目录维护
					map("<leader>wa", vim.lsp.buf.add_workspace_folder, "workspace: [a]dd")
					map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "workspace: [r]emove")
					map("<leader>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, "workspace: [l]ist")

					map("gi", vim.lsp.buf.incoming_calls, "goto [i]ncoming_calls")
					map("go", vim.lsp.buf.outgoing_calls, "goto [o]utming_calls")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>ch", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "code: [h]int")
					end

					-- 尝试启用LSP自带的折叠功能
					if
						client
						and client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange, event.buf)
					then
						local win = vim.api.nvim_get_current_win()
						vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
					end

					-- 增加navic代码导航栏（绑定后供winbar、statusline等控件使用）
					if client and client.server_capabilities.documentSymbolProvider then
						require("nvim-navic").attach(client, event.buf)
					end

					-- sqls数据库插件绑定
					-- if client and client.name == "sqls" then
					-- 	require("sqls").on_attach(client, event.buf)
					-- end

					-- java jdtls额外命令
					if client and client.name == "jdtls" then
						map("<leader>ei", require("jdtls").organize_imports, "organize [i]mports", { "n" })
						map("<leader>ev", require("jdtls").extract_variable, "extract [v]ariable", { "n", "v" })
						map("<leader>ec", require("jdtls").extract_constant, "extract [c]onstant", { "n", "v" })
						map("<leader>em", require("jdtls").extract_method, "extract [m]ethod", { "n", "v" })
					end

					local cwd = vim.fn.getcwd()
					-- 规范化目录分隔符为/，windows上为\
					cwd = string.gsub(cwd, "\\", "/")

					-- python项目根目录cwd及src目录加入到LSP搜索目录中，避免代码无法跳转
					if client and client.name == "pyright" then
						local extraPaths = { cwd, cwd .. "/src" }
						local workspace_folders = vim.lsp.buf.list_workspace_folders()
						for _, folder in ipairs(extraPaths) do
							if vim.fn.isdirectory(folder) == 1 and not vim.tbl_contains(workspace_folders, folder) then
								vim.lsp.buf.add_workspace_folder(folder)
							end
						end

						client.settings.python.analysis.extraPaths = extraPaths -- pyright
						-- 排除扫描目录，降低pyright内存消耗
						client.settings.python.analysis.exclude =
							{ "**/node_modules", "**/__pycache__", "**/.venv", "**/site-packages" }
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				clangd = {},
				-- gopls = {},

				-- pyright侧重于类型检查，ruff负责lint、import、快速修复
				-- https://microsoft.github.io/pyright/#/settings
				pyright = {
					-- 	settings = {
					-- 		-- pyright = {
					-- 		-- 			-- disableLanguageServices = false, -- 保持基础 LSP 功能
					-- 		-- 			disableOrganizeImports = true, -- 关闭 Pyright 自带的 import 整理
					-- 		-- 		},
					-- 		python = {
					-- 			analysis = {
					-- 				extraPaths = { "." },
					-- 				-- 				-- useLibraryCodeForTypes = true,
					-- 				-- 				-- diagnosticSeverityOverrides = {
					-- 				-- 				-- 	reportUnusedImport = "none", -- 禁用未使用导入的提示
					-- 				-- 				-- },
					-- 				-- 				-- autoImportCompletions = true,
					-- 				-- 				-- typeCheckingMode = "strict",
					-- 				-- 				-- diagnosticMode = "workspace", -- 降低实时诊断频率
					-- 				-- 				linting = { enabled = false }, -- 彻底关闭 Pyright 的 lint 功能
					-- 				--
					-- 				-- 				-- Ignore all files for analysis to exclusively use Ruff for linting
					-- 				-- 				-- ignore = { "*" },
					-- 			},
					-- 		},
					-- 	},
				},

				-- https://docs.astral.sh/ruff/editors/settings/
				ruff = {
					-- 	settings = {
					-- 		init_options = {
					-- 			settings = {
					-- 				args = { "--fix-only", "--select=ALL" }, -- 全量规则 + 自动修复
					-- 				organizeImports = true, -- 接管 imports 整理
					-- 				lint = { enable = true },
					-- 			},
					-- 		},
					-- 		-- 增强 Ruff 的代码操作优先级
					-- 		-- capabilities = require("cmp_nvim_lsp").default_capabilities().textDocument.codeAction,
					-- 	},
				},

				-- rust_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--
				stylua = {}, -- Used to format Lua code

				-- Special Lua Config, as recommended by neovim help docs
				lua_ls = {
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								version = "LuaJIT",
								path = { "lua/?.lua", "lua/?/init.lua" },
							},
							workspace = {
								checkThirdParty = false,
								-- NOTE: this is a lot slower and will cause issues when working on your own configuration.
								--  See https://github.com/neovim/nvim-lspconfig/issues/3189
								library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
									"${3rd}/luv/library",
									"${3rd}/busted/library",
								}),
							},
						})
					end,
					settings = {
						Lua = {},
					},
				},

				-- sqls = {
				-- 	settings = {
				-- 		sqls = { -- https://github.com/sqls-server/sqls
				-- 			connections = {
				-- 				{
				-- 					driver = "mysql",
				-- 					dataSourceName = "root:root@tcp(127.0.0.1:3306)/world",
				-- 				},
				-- 				{
				-- 					driver = "postgresql",
				-- 					dataSourceName = "host=127.0.0.1 port=15432 user=postgres password=mysecretpassword1234 dbname=dvdrental sslmode=disable",
				-- 				},
				-- 			},
				-- 		},
				-- 	},
				-- },

				-- ltex配置不起作用，暂不知原因
				ltex = {
					filetypes = { "latex", "tex", "bibtex", "markdown" }, -- 仅保留必要类型
					settings = {
						ltex = {
							enabled = { "latex", "markdown" }, -- 关闭 gitcommit 等无关功能
							-- 禁用耗时检查
							checkers = {
								latex = { enable = false }, -- 关闭 LaTeX 语法检查
								spelling = { enable = false }, -- 关闭拼写检查
							},
						},
					},
				},
			}

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
				"lua_ls",
				"pyright",
				"ruff",
				-- "jdtls", -- jdtls目前为独立的插件（nvim-jdtls），不在mason系统中管理
			})

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			-- require("mason").setup({
			-- 	ui = {
			-- 		icons = {
			-- 			package_installed = "✓",
			-- 			package_pending = "➜",
			-- 			package_uninstalled = "✗",
			-- 		},
			-- 	},
			-- })

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			-- require("mason-lspconfig").setup({
			-- 	ensure_installed = {},
			-- 	automatic_installation = false,
			-- 	handlers = {
			-- 		function(server_name)
			-- 			local server = servers[server_name] or {}
			-- 			-- This handles overriding only values explicitly passed
			-- 			-- by the server configuration above. Useful when disabling
			-- 			-- certain features of an LSP (for example, turning off formatting for ts_ls)
			-- 			server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
			--
			-- 			-- jdtls目前为独立的插件（nvim-jdtls），不在mason系统中管理
			-- 			if server_name ~= "jdtls" then
			-- 				require("lspconfig")[server_name].setup(server)
			-- 			end
			-- 		end,
			-- 	},
			-- })

			-- 启用LSP
			for name, server in pairs(servers) do
				vim.lsp.config(name, server)
				vim.lsp.enable(name)
			end
		end,
	},
	{ -- LSP文件操作
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Uncomment whichever supported plugin(s) you use
			-- "nvim-tree/nvim-tree.lua",
			"nvim-neo-tree/neo-tree.nvim",
			-- "simonmclean/triptych.nvim"
		},
		config = function()
			require("lsp-file-operations").setup()
		end,
	},
	-- { -- hover信息美化
	-- 	"Fildo7525/pretty_hover",
	-- 	event = "LspAttach",
	-- 	opts = {},
	-- },
	{ -- Autocompletion
		"saghen/blink.cmp",
		-- event = "VimEnter",
		event = { "BufReadPre", "BufNewFile" },
		version = "1.*",
		dependencies = {
			-- "Kaiser-Yang/blink-cmp-avante",
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					{
						"rafamadriz/friendly-snippets",
						config = function()
							-- 默认片段文件
							require("luasnip.loaders.from_vscode").lazy_load()
							-- 自定义片段文件（snipmate格式）
							require("luasnip.loaders.from_snipmate").lazy_load({ paths = "./snippets" })
						end,
					},
				},
				opts = {},
			},
			"folke/lazydev.nvim",

			"xzbdmw/colorful-menu.nvim",
		},

		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			cmdline = {
				keymap = {
					-- ["<cr>"] = { "select_and_accept", "fallback" },
				},
				completion = {
					-- Whether to automatically show the window when new completion items are available
					menu = { auto_show = true },
					-- Displays a preview of the selected item on the current line
					ghost_text = { enabled = false },
				},
			},
			keymap = {
				-- 'default' (recommended) for mappings similar to built-in completions
				--   <c-y> to accept ([y]es) the completion.
				--    This will auto-import if your LSP supports it.
				--    This will expand snippets if the LSP sent a snippet.
				-- 'super-tab' for tab to accept
				-- 'enter' for enter to accept
				-- 'none' for no mappings
				--
				-- For an understanding of why the 'default' preset is recommended,
				-- you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				--
				-- All presets have the following mappings:
				-- <tab>/<s-tab>: move to right/left of your snippet expansion
				-- <c-space>: Open menu or open docs if already open
				-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
				-- <c-e>: Hide menu
				-- <c-k>: Toggle signature help
				--
				-- See :h blink-cmp-config-keymap for defining your own keymap
				preset = "default",

				-- Tab键与fittencode冲突了，改为其他键
				["<Tab>"] = false, -- or {}
				["<C-Tab>"] = { "snippet_forward", "fallback" },

				-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
				--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			completion = {
				menu = {
					draw = {
						-- We don't need label_description now because label and label_description are already
						-- combined together in label by colorful-menu.nvim.
						columns = { { "kind_icon" }, { "label", gap = 1 } },
						components = {
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
						},
					},
				},
				-- By default, you may press `<c-space>` to show the documentation.
				-- Optionally, set `auto_show = true` to show the documentation after a delay.
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
			},

			sources = {
				-- "avante", "codecompanion"
				default = { "lsp", "path", "snippets", "buffer", "lazydev" },
				per_filetype = {
					codecompanion = { "codecompanion" },
					-- sql = { "snippets", "dadbod", "buffer" },
				},
				providers = {
					-- avante = {
					-- 	module = "blink-cmp-avante",
					-- 	name = "Avante",
					-- 	opts = {
					-- 		-- options for blink-cmp-avante
					-- 	},
					-- },
					-- dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
					lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 5 },
					fittencode = {
						name = "fittencode",
						module = "fittencode.sources.blink",
						score_offset = 10,
					},
					buffer = {
						opts = {
							-- get all but "normal" buffers (recommended)
							get_bufnrs = function()
								return vim.tbl_filter(function(bufnr)
									return vim.bo[bufnr].buftype == ""
								end, vim.api.nvim_list_bufs())
							end,
						},
					},
				},
			},

			snippets = { preset = "luasnip" },

			-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
			-- which automatically downloads a prebuilt binary when enabled.
			--
			-- By default, we use the Lua implementation instead, but you may enable
			-- the rust implementation via `'prefer_rust_with_warning'`
			--
			-- See :h blink-cmp-config-fuzzy for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },

			-- Shows a signature help window while you type arguments for a function
			signature = { enabled = true },
		},
		opts_extend = { "sources.default" },
	},
	{ -- AI辅助
		"luozhiya/fittencode.nvim",
		-- event = "VeryLazy",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- Default keymaps
			use_default_keymaps = true,
			-- log = {
			-- 	level = vim.log.levels.TRACE,
			-- },
		},
	},
	-- { -- 写代码AI辅助
	-- 	"tzachar/cmp-tabnine",
	-- 	event = "InsertEnter",
	-- 	build = "powershell ./install.ps1",
	-- 	dependencies = "hrsh7th/nvim-cmp",
	-- },

	-- { -- 类似CursorIDE的AI插件
	-- 	"yetone/avante.nvim",
	-- 	event = "VeryLazy",
	-- 	lazy = false,
	-- 	version = false, -- set this if you want to always pull the latest change
	-- 	build = function()
	-- 		-- conditionally use the correct build system for the current OS
	-- 		if vim.fn.has("win32") == 1 then
	-- 			return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
	-- 		else
	-- 			return "make"
	-- 		end
	-- 	end,
	-- 	--@module 'avante'
	-- 	--@type avante.Config
	-- 	opts = {
	-- 		provider = "p1",
	-- 		providers = {
	-- 			openai = {
	-- 				hide_in_model_selector = true,
	-- 			},
	-- 			vertex = {
	-- 				hide_in_model_selector = true,
	-- 			},
	-- 			vertex_claude = {
	-- 				hide_in_model_selector = true,
	-- 			},
	-- 			p1 = {
	-- 				disable_tools = true,
	-- 				__inherited_from = "openai",
	-- 				hide_in_model_selector = false,
	-- 				endpoint = "https://openrouter.ai/api/v1",
	-- 				api_key_name = "OPENROUTER_API_KEY",
	-- 				model = "deepseek/deepseek-r1-0528:free",
	-- 			},
	-- 			p2 = {
	-- 				disable_tools = true,
	-- 				__inherited_from = "openai",
	-- 				hide_in_model_selector = false,
	-- 				endpoint = "https://openrouter.ai/api/v1",
	-- 				api_key_name = "OPENROUTER_API_KEY",
	-- 				model = "qwen/qwen3-coder:free",
	-- 			},
	-- 			p3 = {
	-- 				disable_tools = true,
	-- 				__inherited_from = "openai",
	-- 				hide_in_model_selector = false,
	-- 				endpoint = "https://openrouter.ai/api/v1",
	-- 				api_key_name = "OPENROUTER_API_KEY",
	-- 				model = "z-ai/glm-4.5-air:free",
	-- 			},
	-- 		},
	-- 	},
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"MunifTanjim/nui.nvim",
	-- 		--- The below dependencies are optional,
	-- 		"nvim-tree/nvim-web-devicons", -- or nvim-mini/mini.icons
	-- 		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
	-- 		"zbirenbaum/copilot.lua", -- for providers='copilot'
	-- 		-- "stevearc/dressing.nvim",
	-- 		-- "folke/snacks.nvim",
	-- 		{
	-- 			-- support for image pasting
	-- 			"HakonHarnes/img-clip.nvim",
	-- 			event = "VeryLazy",
	-- 			opts = {
	-- 				-- recommended settings
	-- 				default = {
	-- 					embed_image_as_base64 = false,
	-- 					prompt_for_file_name = false,
	-- 					drag_and_drop = {
	-- 						insert_mode = true,
	-- 					},
	-- 					-- required for Windows users
	-- 					use_absolute_path = true,
	-- 				},
	-- 			},
	-- 		},
	-- 		{
	-- 			-- Make sure to set this up properly if you have lazy=true
	-- 			"MeanderingProgrammer/render-markdown.nvim",
	-- 			opts = {
	-- 				file_types = { "markdown", "Avante" },
	-- 			},
	-- 			ft = { "markdown", "Avante" },
	-- 		},
	-- 	},
	-- },
	{ -- AI辅助，目前高频使用，不要延迟加载
		"olimorris/codecompanion.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{ "gp", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n" }, desc = "ai: [c]hat" },
		},
		config = function()
			--https://github.com/olimorris/codecompanion.nvim/issues/2270
			require("codecompanion").setup({
				-- opts = { language = "Chinese", log_level = "INFO" },
				-- tools = { enabled = false },
				interactions = {
					-- 默认用魔搭，硅基流动的模型相对贵，openrouter免费模型频繁下线
					chat = {
						adapter = "_modelscope",
						roles = {
							llm = function(adapter)
								-- 模型名称类似于abc/def/ghi，只取最后一个ghi
								return "Ai: " .. adapter.name .. "." .. adapter.model.name:match("([^/]+)$")
							end,
							user = "Me: CodeCompanion",
						},
						variables = {},
					},
					inline = { adapter = "_modelscope" },
				},
				adapters = {
					http = {
						_modelscope = function()
							return require("codecompanion.adapters").extend("openai_compatible", {
								env = {
									url = "https://api-inference.modelscope.cn",
									api_key = "MODELSCOPE_ACCESS_TOKEN",
									chat_url = "/v1/chat/completions",
								},
								schema = {
									model = {
										default = "Qwen/Qwen3-Coder-30B-A3B-Instruct",
										choices = {
											"Qwen/Qwen3-Coder-30B-A3B-Instruct",
											"Qwen/Qwen3-Next-80B-A3B-Instruct",
											"ZhipuAI/GLM-5",
											"MiniMax/MiniMax-M2.5",
											"moonshotai/Kimi-K2.5",
											"Qwen/Qwen3-Coder-480B-A35B-Instruct",
											"deepseek-ai/DeepSeek-V3.2",
										},
									},
								},
								handlers = {
									-- AI请求执行完成时，解析响应头获取配额信息
									-- https://github.com/olimorris/codecompanion.nvim/discussions/2395
									on_exit = function(self, data)
										-- Extract quota information
										local quota_info = {}

										local model_name = nil
										-- Extract model name from body
										if data.body then
											model_name = string.match(data.body, '"model":"([^"]+)"')
										end

										if not model_name or not data.headers then
											return
										end

										-- 响应头中包含配额信息，以key: value这样的字符串形式传输，需要解析
										-- Parse headers to extract key-value pairs
										local parsed_headers = {}
										for _, header_string in ipairs(data.headers) do
											-- Split by first colon and space
											local key, value = string.match(header_string, "([^:]+):%s*(.+)")
											if key and value then
												parsed_headers[key] = value
											end
										end

										-- Define mappings for Modelscope headers
										local mappings = {
											-- ["Modelscope-Ratelimit-Requests-Limit"] = "user_daily_limit",
											-- ["Modelscope-Ratelimit-Requests-Remaining"] = "user_daily_remain",
											-- ["Modelscope-Ratelimit-Model-Requests-Limit"] = "model_daily_limit",
											["Modelscope-Ratelimit-Model-Requests-Remaining"] = "model_daily_remain",
										}

										quota_info["model_name"] = model_name
										for header, quota_item in pairs(mappings) do
											if parsed_headers[header] then
												quota_info[quota_item] = parsed_headers[header]
											end
										end

										-- Store model_name and model_daily_remain in global variable
										if model_name and quota_info.model_daily_remain and _G.MODEL_QUOTA_INFO then
											_G.MODEL_QUOTA_INFO["modelscope." .. model_name] =
												quota_info.model_daily_remain
											vim.notify(
												string.format(
													"%s 剩余额度: %s",
													model_name,
													quota_info.model_daily_remain
												)
											)
										end

										-- vim.notify(string.format("模型额度信息: %s", vim.inspect(quota_info)))
									end,
								},
							})
						end,
						_siliconflow = function()
							return require("codecompanion.adapters").extend("openai_compatible", {
								env = {
									url = "https://api.siliconflow.cn",
									api_key = "SILICONFLOW_API_KEY",
									chat_url = "/v1/chat/completions",
								},
								schema = {
									model = {
										default = "deepseek-ai/DeepSeek-V3.2",
										choices = {
											"deepseek-ai/DeepSeek-V3.2",
											"stepfun-ai/Step-3.5-Flash",
											"Qwen/Qwen3-Coder-30B-A3B-Instruct",
											"Pro/deepseek-ai/DeepSeek-V3.2",
											"Pro/zai-org/GLM-5",
											"Pro/moonshotai/Kimi-K2.5",
											"Pro/MiniMaxAI/MiniMax-M2.5",
										},
									},
								},
							})
						end,
					},
				},
				extensions = {
					mcphub = {
						callback = "mcphub.extensions.codecompanion",
						opts = {
							-- MCP Tools
							make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
							show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
							add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
							show_result_in_chat = true, -- Show tool results directly in chat buffer
							format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
							-- MCP Resources
							make_vars = true, -- Convert MCP resources to #variables for prompts
							-- MCP Prompts
							make_slash_commands = true, -- Add MCP prompts as /slash commands
						},
					},
					history = {
						enabled = true,
						opts = {
							-- Keymap to open history from chat buffer (default: gh)
							keymap = "gh",
							-- Keymap to save the current chat manually (when auto_save is disabled)
							-- save_chat_keymap = "sc",
						},
					},
				},
			})

			-- 自定义快捷键
			vim.keymap.set(
				{ "n", "v" },
				"<leader>ca",
				"<cmd>CodeCompanionActions<cr>",
				{ noremap = true, silent = true, desc = "ai: [a]ction" }
			)
			-- vim.keymap.set(
			-- 	{ "n", "v" },
			-- 	"<leader>cc",
			-- 	"<cmd>CodeCompanionChat Toggle<cr>",
			-- 	{ noremap = true, silent = true, desc = "ai: [c]hat" }
			-- )
			vim.keymap.set("v", "gP", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
			-- Expand 'cc' into 'CodeCompanion' in the command line
			vim.cmd([[cab cc CodeCompanion]])

			-- 增加hook拦截，竖屏模式下codecompanion窗口置底
			local hooks_group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
			vim.api.nvim_create_autocmd({ "User" }, {
				pattern = "CodeCompanion*",
				group = hooks_group,
				callback = function(request)
					if request.match == "CodeCompanionChatOpened" then
						if require("core/utils").is_vertical_screen() then
							if vim.bo.filetype == "codecompanion" then
								vim.cmd("wincmd J")
							end
						end
					end
				end,
			})

			-- 全局变量：模型额度信息
			_G.MODEL_QUOTA_INFO = {}
			local function show_model_quota()
				vim.notify(string.format("模型剩余额度: %s", vim.inspect(_G.MODEL_QUOTA_INFO)))
			end
			vim.keymap.set("n", "<leader>cq", show_model_quota, { desc = "ai: [q]uota" })

			-- 进度提醒
			require("plug.fidget-spinner"):init()
		end,

		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/codecompanion-history.nvim",
			"j-hui/fidget.nvim",
		},
	},
	{
		"ravitemer/mcphub.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
		config = function()
			require("mcphub").setup()
		end,
	},
	-- { -- codeium
	-- 	"Exafunction/codeium.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"hrsh7th/nvim-cmp",
	-- 	},
	-- 	config = function()
	-- 		require("codeium").setup({})
	-- 	end,
	-- },
	-- "hrsh7th/cmp-nvim-lsp-signature-help",
	-- { -- 函数签名提醒
	-- 	"ray-x/lsp_signature.nvim",
	-- 	-- event = "VeryLazy",
	-- 	opts = {
	-- 		bind = true,
	-- 		handler_opts = {
	-- 			border = "rounded",
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("lsp_signature").setup(opts)
	-- 	end,
	-- },

	--其他lsp服务

	-- { -- pyright专用自动import工具，不好用！
	-- 	"stevanmilic/nvim-lspimport",
	-- 	lazy = true,
	-- 	ft = "python",
	-- },
	-- { --维护python import
	-- 	-- 若PympleBuild安装报错，可手动安装cargo
	-- 	"alexpasmantier/pymple.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"MunifTanjim/nui.nvim",
	-- 		-- optional (nicer ui)
	-- 		"stevearc/dressing.nvim",
	-- 		"nvim-tree/nvim-web-devicons",
	-- 	},
	-- 	build = ":PympleBuild",
	-- 	config = function()
	-- 		require("pymple").setup({
	-- 			logging = {
	-- 				level = "debug",
	-- 			},
	-- 		})
	-- 	end,
	-- },
	-- ,
	{
		"piersolenski/import.nvim",
		dependencies = {
			-- One of the following pickers is required:
			"nvim-telescope/telescope.nvim",
			-- 'folke/snacks.nvim',
			-- 'ibhagwan/fzf-lua',
		},
		opts = {
			picker = "telescope",
		},
		keys = {
			{
				"<leader>ci",
				function()
					require("import").pick()
				end,
				desc = "code: [i]mport",
			},
		},
	},
	-- "relastle/vim-nayvy", -- windows上一直警告cannot load project
	{
		"mfussenegger/nvim-jdtls", -- java代码lsp增强（eclipse.jdt.ls）
		dependencies = { "nvim-dap" },
		ft = { "java" },
		-- 参考https://github.com/mfussenegger/nvim-jdtls/wiki/Sample-Configurations
		config = function()
			local config = {
				-- The command that starts the language server
				-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
				cmd = {
					-- 💀
					"java", -- or '/path/to/java21_or_newer/bin/java'
					-- depends on if `java` is in your $PATH env variable and if it points to the right version.

					"-Declipse.application=org.eclipse.jdt.ls.core.id1",
					"-Dosgi.bundles.defaultStartLevel=4",
					"-Declipse.product=org.eclipse.jdt.ls.core.product",
					"-Dlog.protocol=true",
					"-Dlog.level=ALL",
					"-Xmx1g",
					"--add-modules=ALL-SYSTEM",
					"--add-opens",
					"java.base/java.util=ALL-UNNAMED",
					"--add-opens",
					"java.base/java.lang=ALL-UNNAMED",

					-- 💀
					"-jar",
					vim.fn.expand(
						"~/AppData/Local/nvim-data/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"
					),
					-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
					-- Must point to the                                                     Change this to
					-- eclipse.jdt.ls installation                                           the actual version

					-- 💀
					"-configuration",
					vim.fn.expand("~/AppData/Local/nvim-data/mason/packages/jdtls/config_win"),
					-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
					-- Must point to the                      Change to one of `linux`, `win` or `mac`
					-- eclipse.jdt.ls installation            Depending on your system.

					-- 💀
					-- See `data directory configuration` section in the README
					"-data",
					vim.fn.expand("~/.cache/jdtls/workspace/"),
				},

				-- 💀
				-- This is the default if not provided, you can remove it. Or adjust as needed.
				-- One dedicated LSP server & client will be started per unique root_dir
				--
				-- vim.fs.root requires Neovim 0.10.
				-- If you're using an earlier version, use: require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
				root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }),

				-- Here you can configure eclipse.jdt.ls specific settings
				-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
				-- for a list of options
				settings = {
					java = {},
				},

				-- Language server `initializationOptions`
				-- You need to extend the `bundles` with paths to jar files
				-- if you want to use additional eclipse.jdt.ls plugins.
				--
				-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
				--
				-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
				init_options = {
					bundles = {
						vim.fn.glob(
							"C:/Users/luocm/AppData/Local/nvim-data/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
							1
						),
					},
				},
			}

			-- This starts a new client & server,
			-- or attaches to an existing client & server depending on the `root_dir`.
			require("jdtls").start_or_attach(config)
		end,
	},
	-- "nanotee/sqls.nvim", -- sql服务器（仅支持mysql少量数据库）
	-- { -- 数据库访问终端DBUI
	-- 	"kristijanhusak/vim-dadbod-ui", -- 实测不好用
	-- 	dependencies = {
	-- 		{ "tpope/vim-dadbod", lazy = true },
	-- 		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
	-- 	},
	-- 	cmd = {
	-- 		"DBUI",
	-- 		"DBUIToggle",
	-- 		"DBUIAddConnection",
	-- 		"DBUIFindBuffer",
	-- 	},
	-- 	init = function()
	-- 		-- Your DBUI configuration
	-- 		vim.g.db_ui_use_nerd_fonts = 1
	-- 	end,
	-- },
	{ -- dbee数据库UI终端
		"kndndrj/nvim-dbee",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			-- Install tries to automatically detect the install method.
			-- if it fails, try calling it with one of these parameters:
			--    "curl", "wget", "bitsadmin", "go"
			-- 这一步如果未被Mason调用，则手动执行下
			require("dbee").install("go")
		end,
		config = function()
			require("dbee").setup(--[[optional config]])
		end,
	},

	-- { -- rest客户端（GET/POST请求），由于lua有5.1、5.4版本混乱导致build失败！
	-- 	"rest-nvim/rest.nvim",
	-- 	dependencies = {
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 		opts = function(_, opts)
	-- 			opts.ensure_installed = opts.ensure_installed or {}
	-- 			table.insert(opts.ensure_installed, "http")
	-- 		end,
	-- 	},
	-- },

	{ -- rest客户端
		"mistweaverco/kulala.nvim",
		ft = { "http", "rest" },
		opts = {
			-- your configuration comes here
			global_keymaps = true,
			global_keymaps_prefix = "<leader>r",
			kulala_keymaps_prefix = "",
		},
	},

	-- lua LSP
	{ -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		event = "VeryLazy",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ "nvim-dap-ui" },
			},
		},
	},
	"kosayoda/nvim-lightbulb", -- code action提示灯泡
	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		-- event = "VeryLazy",
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>bf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "buffer: [f]ormat",
			},
		},
		---@module 'conform'
		---@type conform.setupOpts
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = {
					"ruff_fix", -- fix lint errors. (ruff with argument --fix)
					"ruff_format", -- run the formatter. (ruff with argument format)",
				},
				-- python = { "isort", "black" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd" },
			},
			default_format_opts = {
				lsp_format = "fallback",
			},
			-- Set up format-on-save
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,

			-- Customize formatters
			formatters = {
				lua = { "stylua" },
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
			init = function()
				-- If you want the formatexpr, here is the place to set it
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
		},
	},
	{ -- 代码导航面包屑
		"SmiteshP/nvim-navic",
		-- event = "VeryLazy",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- lsp = { auto_attach = true },
			depth_limit = 2,
		},
		-- dependencies = { "neovim/nvim-lspconfig" },
	},
	-- { -- barbecue代码导航面包屑，改为navic+lualine显示到状态栏中
	-- 	"utilyre/barbecue.nvim",
	-- 	event = "VeryLazy",
	-- 	name = "barbecue",
	-- 	version = "*",
	-- 	dependencies = {
	-- 		"SmiteshP/nvim-navic",
	-- 		"nvim-tree/nvim-web-devicons", -- optional dependency
	-- 	},
	-- 	opts = {
	-- 		-- configurations go here
	-- 		show_dirname = false,
	-- 		-- show_basename = false,
	-- 	},
	-- },
	-- "liuchengxu/vista.vim", -- 代码大纲展示
	{ -- aerial代码大纲展示（轻量级，比vista更轻便高效、清单更完整）
		"stevearc/aerial.nvim",
		-- event = "VeryLazy",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
		-- Optional dependencies
		config = function()
			require("aerial").setup({
				-- optionally use on_attach to set keymaps when aerial has attached to a buffer
				on_attach = function(bufnr)
					-- Jump forwards/backwards with '{' and '}'
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
					vim.keymap.set("n", "<F2>", "<cmd>AerialToggle!<CR>", { buffer = bufnr })
				end,
			})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},

	{ -- Make sure to set this up properly if you have lazy=true
		"MeanderingProgrammer/render-markdown.nvim",
		-- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
		opts = {
			file_types = { "markdown", "Avante", "codecompanion" },
		},
		ft = { "markdown", "Avante", "codecompanion" },
	},

	-- { -- litee插件
	-- 	"ldelossa/litee.nvim",
	-- 	event = "VeryLazy",
	-- 	opts = {
	-- 		notify = { enabled = false },
	-- 		panel = {
	-- 			orientation = "bottom",
	-- 			panel_size = 10,
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("litee.lib").setup(opts)
	-- 	end,
	-- },
	-- { -- litee-calltree调用树incoming/outgoing calls
	-- 	"ldelossa/litee-calltree.nvim",
	-- 	dependencies = "ldelossa/litee.nvim",
	-- 	event = "VeryLazy",
	-- 	opts = {
	-- 		on_open = "panel",
	-- 		map_resize_keys = false,
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("litee.calltree").setup(opts)
	-- 	end,
	-- },
	{ -- Comment注释
		"numToStr/Comment.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("Comment").setup()
		end,
	},
	-- { -- 自动补全括号
	-- 	"windwp/nvim-autopairs",
	-- 	event = "InsertEnter",
	-- 	opts = {},
	-- },
	{ -- mini插件Collection of various small independent plugins/modules
		"nvim-mini/mini.nvim",
		event = "VimEnter",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - --[[ [V] ]]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			-- 修改映射，保持键位与vim-surround一致，腾出s键给flash使用
			require("mini.surround").setup({
				mappings = {
					add = "ys",
					delete = "ds",
					find = "",
					find_left = "",
					highlight = "",
					replace = "cs",
					update_n_lines = "",

					-- Add this only if you don't want to use extended mappings
					suffix_last = "",
					suffix_next = "",
				},
				search_method = "cover_or_next",
			})
			-- Remap adding surrounding to Visual mode selection
			-- vim.keymap.del("x", "ys")
			-- vim.keymap.set("x", "M", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

			-- Make special mapping for "add surrounding for line"
			vim.keymap.set("n", "yss", "ys_", { remap = true })

			-- 不支持Comment插件gcA功能，暂时关闭
			-- require("mini.comment").setup()

			-- 文件夹浏览浮窗
			require("mini.files").setup()

			-- 括号中内容拆分合并（默认快捷键gS，改为gs更方便），改用ts-node-action
			-- require("mini.splitjoin").setup({ mappings = { toggle = "gs" } })

			-- ]x/[x快速跳转缓冲区、代码位置等，会占用]I键，不方便
			-- require("mini.bracketed").setup()

			-- tabline插件，改用barbar.nvim
			-- require("mini.tabline").setup({ tabpage_section = "right" })

			-- 光标位置文字高亮
			require("mini.cursorword").setup()

			-- 尾随空格高亮及删除
			require("mini.trailspace").setup()

			-- 当前位置缩进提示
			require("mini.indentscope").setup({
				mappings = {
					-- indent跳转，不要占用[i/]i系统预定义按键
					goto_top = "[e",
					goto_bottom = "]e",
				},
				symbol = ".",
			})

			-- 操作符保留默认的exchange，即gx命令
			require("mini.operators").setup({
				evaluate = { prefix = "" }, -- 默认为g=
				multiply = { prefix = "" }, -- 默认为gm
				replace = { prefix = "" }, -- 默认为gr
				sort = { prefix = "" }, -- 默认为gs
			})
			-- 平替nvim-autopairs插件
			require("mini.pairs").setup()

			-- 补全辅助，动态提示函数参数，和cmp集成有bug
			-- 换用"ray-x/lsp_signature.nvim"
			-- require("mini.completion").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			-- local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			-- statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			-- -@diagnostic disable-next-line: duplicate-set-field
			-- statusline.section_location = function()
			-- 	return "%2l:%-2v"
			-- end

			-- 按键映射优化
			require("mini.keymap").setup()
			local map_combo = require("mini.keymap").map_combo

			-- Support most common modes. This can also contain 't', but would
			-- only mean to press `<Esc>` inside terminal.
			-- To not have to worry about the order of keys, also map "kj"
			local mode = { "i", "c", "x", "s" }
			map_combo(mode, "jk", "<BS><BS><Esc>")
			map_combo(mode, "kj", "<BS><BS><Esc>")

			-- Escape into Normal mode from Terminal mode
			map_combo("t", "jk", "<BS><BS><C-\\><C-n>")
			map_combo("t", "kj", "<BS><BS><C-\\><C-n>")

			-- 文本块移动
			require("mini.move").setup()

			-- 文本块对齐
			require("mini.align").setup()

			-- ... and there is more!
			--  Check out: https://github.com/nvim-mini/mini.nvim
		end,
	},
	{ -- todo注释Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{ -- 生成类、函数的docstring
		"danymat/neogen",
		config = true,
	},
	{ -- gitsigns：Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim", -- 左侧git提示
		---@module 'gitsigns'
		---@type Gitsigns.Config
		---@diagnostic disable-next-line: missing-fields
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{ -- git提交
		"NeogitOrg/neogit",
		-- event = "VeryLazy",
		lazy = true,
		-- cmd = { "Neogit" },
		keys = {
			{ "<leader>wn", "<cmd>Neogit<cr>", desc = "workspace: [n]eogit" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			-- "ibhagwan/fzf-lua",              -- optional
			-- "nvim-mini/mini.pick",         -- optional
		},
		config = true,
	},
	{ -- telescope, Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		enabled = true,
		event = "VimEnter",
		-- lazy = true,
		keys = {
			--通过打开会话窗口，实现telescope延迟加载的效果
			{ "<leader>wo", "<cmd>AutoSession search<CR>", desc = "session: [o]pen" },
		},
		-- branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			-- { "debugloop/telescope-undo.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- Telescope is a fuzzy finder that comes with a lot of different things that
			-- it can fuzzy find! It's more than just a "file finder", it can search
			-- many different aspects of Neovim, your workspace, LSP, and more!
			--
			-- The easiest way to use Telescope, is to start by doing something like:
			--  :Telescope help_tags
			--
			-- After running this command, a window will open up and you're able to
			-- type in the prompt window. You'll see a list of `help_tags` options and
			-- a corresponding preview of the help.
			--
			-- Two important keymaps to use while in Telescope are:
			--  - Insert mode: <c-/>
			--  - Normal mode: ?
			--
			-- This opens a window that shows you all of the keymaps for the current
			-- Telescope picker. This is really useful to discover what Telescope can
			-- do as well as how to actually do it!

			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			require("telescope").setup({
				-- You can put your default mappings / updates / etc. in here
				--  All the info you're looking for is in `:help telescope.setup()`
				--
				defaults = {
					mappings = {
						i = {
							["<c-enter>"] = "to_fuzzy_refine",
							["<C-Down>"] = "cycle_history_next",
							["<C-Up>"] = "cycle_history_prev",
							-- ["<C-t>"] = require("telescope.actions.layout").toggle_preview,
							-- 切换布局（横竖屏），可兼顾toggle_preview的效果
							["<C-t>"] = require("telescope.actions.layout").cycle_layout_next,
							-- 禁用better-escape的jk键绑定
							["jk"] = false,
							["jj"] = false,
						},
					},
					file_ignore_patterns = { "__pycache__" },
					path_display = { shorten = { len = 4, exclude = { -2, -1 } } },
					-- path_display = { truncate = 3 },
					dynamic_preview_title = true,
					-- trim the indentation at the beginning of presented line in the result window
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--trim", -- add this value
					},
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							-- https://yeripratama.com/blog/customizing-nvim-telescope/
							-- width = 0.99,
							-- height = 0.99,
							width = { padding = 0 },
							height = { padding = 0 },
							prompt_position = "bottom",
							preview_width = 0.5,
						},
						vertical = {
							width = { padding = 0 },
							height = { padding = 0 },
							prompt_position = "bottom",
							preview_height = 0.5,
						},
					},
					preview = {
						hide_on_startup = false,
					},
				},
				-- https://github-wiki-see.page/m/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#mapping-c-d-to-delete-buffer
				pickers = {
					buffers = {
						mappings = {
							i = {
								["<M-d>"] = "delete_buffer",
							},
						},
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
					-- undo = {},
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			-- 集成nvim-notify控件，可执行:Telescope notify
			pcall(require("telescope").load_extension, "notify")
			-- pcall(require("telescope").load_extension, "undo")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>dw", builtin.diagnostics, { desc = "diag: [w]orkspace" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "search: [f]ile" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "search: [g]rep" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "search: [h]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "search: [k]eymap" })
			vim.keymap.set("n", "<leader>so", builtin.oldfiles, { desc = "search: [o]ld file" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "search: [r]esume" })
			vim.keymap.set({ "n", "v" }, "<leader>ss", builtin.grep_string, { desc = "search: [s]tring" })
			vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "search: [t]elescope" })
			vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "search: [b]uffer" })
			vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "search: [c]ommand" })
			-- vim.keymap.set("n", "<leader>su", "<cmd>Telescope undo<cr>", { desc = "search: [u]ndo tree" })

			-- Slightly advanced example of overriding default behavior and theme
			vim.keymap.set("n", "<leader>s/", function()
				-- You can pass additional configuration to Telescope to change the theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "search: [/] fuzzy" })

			-- It's also possible to pass additional configuration options.
			--  See `:help telescope.builtin.live_grep()` for information about particular keys
			vim.keymap.set("n", "<leader>sO", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "search: [O]pen file" })

			-- Shortcut for searching your Neovim configuration files
			vim.keymap.set("n", "<leader>sv", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "search: [v]im file" })

			-- 横竖屏切换后调整布局
			vim.api.nvim_create_autocmd("VimResized", {
				group = vim.api.nvim_create_augroup("TelescopeResizeGroup", { clear = true }),
				callback = function(event)
					local is_vertical = require("core/utils").is_vertical_screen()
					-- lua中实现类似三元运算符的功能condition ? value1 : value2
					require("telescope.config").values.layout_strategy = is_vertical and "vertical" or "horizontal"
				end,
			})
		end,
	},
	{ -- flash闪电移动
		"folke/flash.nvim", -- 闪电移动跳转
		event = "VeryLazy",
		---@type Flash.Config
		-- opts = { labels = "asdfghjklqwertyuiopzxcvbnm123456789" },
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
			{
				"gl",
				mode = { "n" },
				function()
					require("flash").jump(
					---@diagnostic disable-next-line: missing-fields
						{
							search = { mode = "search", max_length = 0 },
							label = { after = { 0, 0 } },
							pattern = "^",
						}
					)
				end,
				desc = "Flash: Jump to line start"
			},
			{
				"gl",
				mode = { "x", "o" },
				function()
					require("flash").jump(
					---@diagnostic disable-next-line: missing-fields
						{
							search = { mode = "search", max_length = 0 },
							pattern = "$",
						}
					)
				end,
				desc = "Flash: Jump to line end"
			},
		},
	},

	{ -- 切换终端
		"akinsho/toggleterm.nvim",
		event = "VeryLazy",
		version = "*",
		config = true,
		opts = {
			size = function(term)
				if term.direction == "horizontal" then
					return 20
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.5
				end
			end,
		},
	},
	-- { -- 处理jk等escape映射，实现零延迟
	-- 	"max397574/better-escape.nvim",
	-- 	config = function()
	-- 		require("better_escape").setup()
	-- 	end,
	-- },

	-- { -- 折叠插件
	-- 	"kevinhwang91/nvim-ufo",
	-- 	event = "VeryLazy",
	-- 	dependencies = { "kevinhwang91/promise-async" },
	-- 	config = function()
	-- 		require("ufo").setup({
	-- 			-- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
	-- 			provider_selector = function(bufnr, filetype, buftype)
	-- 				return { "treesitter", "indent" }
	-- 			end,
	-- 		})
	-- 	end,
	-- },
	-- { -- 折叠预览插件
	-- 	"anuvyklack/fold-preview.nvim",
	-- 	event = "VeryLazy",
	-- 	dependencies = { "anuvyklack/keymap-amend.nvim" },
	-- 	config = function()
	-- 		require("fold-preview").setup({ auto = 400 })
	-- 	end,
	-- },
	{ -- 测试框架暂不可用，持续报错：module 'neotest' not found（详见neotest.log）
		"nvim-neotest/neotest",
		-- commit = "52fca6717ef972113ddd6ca223e30ad0abb2800c",
		lazy = true,
		cmd = { "Neotest" },
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						dap = { justMyCode = false },
						runner = "pytest",
					}),
				},
			})
		end,
	},
	{ -- 测试框架
		"quolpr/quicktest.nvim",
		config = function()
			require("quicktest").setup({
				-- Choose your adapter, here all supported adapters are listed
				adapters = {
					-- require("quicktest.adapters.golang")({}),
					-- require("quicktest.adapters.vitest")({}),
					-- require("quicktest.adapters.playwright")({}),
					require("quicktest.adapters.pytest")({
						cwd = function(bufnr, current)
							return vim.fn.getcwd()
						end,

						env = function(bufnr, current)
							-- 当前工作路径加入PYTHONPATH
							local new_env = vim.deepcopy(current) or {}
							new_env.PYTHONPATH = vim.fn.getcwd() .. ";" .. (os.getenv("PYTHONPATH") or "")
							return new_env
						end,
					}),
					-- require("quicktest.adapters.elixir"),
					-- require("quicktest.adapters.criterion"),
					-- require("quicktest.adapters.dart"),
					-- require("quicktest.adapters.rspec"),
				},
				-- split or popup mode, when argument not specified
				default_win_mode = "split",
				use_builtin_colorizer = true,
			})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<leader>tl",
				function()
					local qt = require("quicktest")
					-- current_win_mode return currently opened panel, split or popup
					qt.run_line()
					-- You can force open split or popup like this:
					-- qt.run_line('split')
					-- qt.run_line('popup')
				end,
				desc = "test: [l]ine",
			},
			{
				"<leader>tf",
				function()
					require("quicktest").run_file()
				end,
				desc = "test: [f]ile",
			},
			{
				"<leader>td",
				function()
					require("quicktest").run_dir()
				end,
				desc = "test: [d]ir",
			},
			{
				"<leader>ta",
				function()
					require("quicktest").run_all()
				end,
				desc = "test: [a]ll",
			},
			{
				"<leader>tp",
				function()
					require("quicktest").run_previous()
				end,
				desc = "test: [p]revious",
			},
			{
				"<leader>tc",
				function()
					require("quicktest").cancel_current_run()
				end,
				desc = "test: [c]ancel",
			},
			{
				"<leader>tt",
				function()
					require("quicktest").toggle_win("split")
				end,
				desc = "test: [t]oggle",
			},
		},
	},

	"tpope/vim-repeat", -- 增强.重复操作
	"ethanholz/nvim-lastplace", -- 回到文件上次编辑位置
	"nvim-pack/nvim-spectre", -- 查找替换插件
	-- { -- 高亮感兴趣词
	-- 	"Mr-LLLLL/interestingwords.nvim",
	-- 	opts = {}, -- needed
	-- },
	{ -- 高亮感兴趣词
		"azabiong/vim-highlighter",
		init = function()
			-- settings
		end,
	},
	{ -- 高亮参数列表
		"m-demare/hlargs.nvim",
		opts = { use_colorpalette = true, sequential_colorpalette = false }, -- needed
	},
	-- "AckslD/swenv.nvim",
	{ -- 切换python虚拟环境
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"mfussenegger/nvim-dap",
			-- "mfussenegger/nvim-dap-python", --optional
			{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
		},
		lazy = true,
		-- branch = "regexp", -- This is the regexp branch, use this for the new version
		config = function()
			require("venv-selector").setup({
				search = {
					global = {
						command = "fd python.exe$ C:/Users/luocm/AppData/Local/Programs/Python/ --max-depth 3 -E scripts -E Scripts",
					},
				},
				-- dap_enabled = true,
			})
		end,
		keys = {
			-- Keymap to open VenvSelector to pick a venv.
			{ "<leader>dv", "<cmd>VenvSelect<cr>", desc = "debug: [v]env" },
			-- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
			-- { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
		},
	},
	{ -- latex文档编写
		"lervag/vimtex",
		lazy = false, -- we don't want to lazy load VimTeX
		-- tag = "v2.15", -- uncomment to pin to a specific release
		init = function()
			-- VimTeX configuration goes here, e.g.
			-- vim.g.vimtex_view_method = "zathura"
		end,
	},
	{ -- markdown插件（md文件、tex公式）
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	{ -- json插件
		"gennaro-tedesco/nvim-jqx",
		event = { "BufReadPost" },
		ft = { "json", "yaml" },
	},
	-- { -- 类jupyter执行效果，qmd文件（quarto类型）执行代码块
	-- 	-- 为了在代码块下显示图片，需要image.nvim插件，但windows上不支持
	-- 	"benlubas/molten-nvim",
	-- 	version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
	-- 	build = ":UpdateRemotePlugins",
	-- 	init = function()
	-- 		-- this is an example, not a default. Please see the readme for more configuration options
	-- 		vim.g.molten_output_win_max_height = 12
	-- 	end,
	-- },
	-- "Shatur/neovim-session-manager", -- 会话管理，不稳定老报错
	{ -- 自动会话管理，不能自动加载LastSession，无法正常恢复nvim-tree
		"rmagatti/auto-session",
		lazy = false,
		keys = {
			-- Will use Telescope if installed or a vim.ui.select picker otherwise
			{ "<leader>wo", "<cmd>AutoSession search<CR>", desc = "session: [o]pen" },
			{ "<leader>ws", "<cmd>AutoSession save<CR>", desc = "session: [s]ave" },
			{ "<leader>wt", "<cmd>AutoSession toggle<CR>", desc = "session: [t]oggle" },
		},
		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			-- log_level = 'debug',
			auto_restore = false,
			auto_create = false,

			-- 保存扩展数据（断点）
			save_extra_data = function(_)
				local ok, breakpoints = pcall(require, "dap.breakpoints")
				if not ok or not breakpoints then
					return
				end

				local bps = {}
				local breakpoints_by_buf = breakpoints.get()

				for buf, buf_bps in pairs(breakpoints_by_buf) do
					bps[vim.api.nvim_buf_get_name(buf)] = buf_bps
				end
				if vim.tbl_isempty(bps) then
					return
				end
				local extra_data = {
					breakpoints = bps,
				}
				return vim.fn.json_encode(extra_data)
			end,

			-- 恢复扩展数据（断点）
			restore_extra_data = function(_, extra_data)
				local function get_buffer_number(fpath)
					local bufnr = vim.fn.bufnr(fpath, true)
					-- Load the file if it wasn't loaded by the session
					if vim.fn.bufloaded(bufnr) == 0 then
						vim.api.nvim_buf_call(bufnr, vim.cmd.edit)
					end
					return bufnr
				end

				local json = vim.fn.json_decode(extra_data)
				if json.breakpoints then
					local ok, breakpoints = pcall(require, "dap.breakpoints")

					if not ok or not breakpoints then
						return
					end

					vim.notify("restoring breakpoints")
					for buf_name, buf_bps in pairs(json.breakpoints) do
						for _, bp in pairs(buf_bps) do
							local line = bp.line
							local opts = {
								condition = bp.condition,
								log_message = bp.logMessage,
								hit_condition = bp.hitCondition,
							}

							-- vim.fn.bufnr()返回的bufnr，可能还未加载，导致断点被设置到第1行
							-- 改用get_buffer_number()函数获取bufnr
							breakpoints.set(opts, get_buffer_number(buf_name), line)
						end
					end
				end
			end,
		},
	},

	{ -- 除了nvim-notify之外，vim.notify可以采用fidget、mini.notify
		"rcarriga/nvim-notify",
		opts = {
			-- #134问题：https://github.com/rcarriga/nvim-notify/issues/134
			background_colour = "#1a1b26",
			top_down = false,
		},
		-- 	config = function()
		-- 		-- 采用vim-notify弹窗插件替换默认通知机制
		-- 		vim.notify = require("notify")
		-- 	end,
	},
	{ -- cmdline、notify框
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				-- override markdown rendering so that other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			presets = {
				-- bottom_search = true, -- use a classic bottom cmdline for search
				-- command_palette = true, -- position the cmdline and popupmenu together
				-- long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
			notify = {
				-- 屏蔽报错：vim.notify has been overwritten by another plugin?
				enabled = false,
			},
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{ -- 跟jupyter交互
		"SUSTech-data/neopyter",
		-- event = "VeryLazy",
		lazy = true,
		cmd = { "Neopyter" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter", -- neopyter don't depend on `nvim-treesitter`, but does depend on treesitter parser of python
			"AbaoFromCUG/websocket.nvim", -- for mode='direct'
		},
		---@type neopyter.Option
		opts = {
			mode = "direct",
			remote_address = "127.0.0.1:9001",
			file_pattern = { "*.ju.*" },
			textobject = {
				enable = true,
				queries = {
					"linemagic",
					"cellseparator",
					"cellcontent",
					"cell",
				},
			},
			on_attach = function(buf)
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = buf })
				end
				map("n", "<leader>js", "<cmd>Neopyter sync current<cr>", "sync current")
				-- same, recommend the former
				map("n", "<C-Enter>", "<cmd>Neopyter execute notebook:run-cell<cr>", "run cell")
				-- map("n", "<C-Enter>", "<cmd>Neopyter run current<cr>", "run cell")
				map("n", "<S-Enter>", "<cmd>Neopyter execute runmenu:run<cr>", "run cell and select next")
				map(
					"n",
					"<M-Enter>",
					"<cmd>Neopyter execute run-cell-and-insert-below<cr>",
					"run cell and insert below"
				)

				-- same, recommend the former
				map("n", "<leader>ja", "<cmd>Neopyter execute notebook:run-all-above<cr>", "run all above cell")
				-- map("n", "<leader>X", "<cmd>Neopyter run allAbove<cr>", "run all above cell")

				-- same, recommend the former, but the latter is silent
				map("n", "<leader>jr", "<cmd>Neopyter execute kernelmenu:restart<cr>", "restart kernel")
				-- map("n", "<leader>nt", "<cmd>Neopyter kernel restart<cr>", "restart kernel")
				map(
					"n",
					"<leader>jR",
					"<cmd>Neopyter execute notebook:restart-run-all<cr>",
					"restart kernel and run all"
				)
			end,
		},
	},
	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		---@module 'which-key'
		---@type wk.Opts
		---@diagnostic disable-next-line: missing-fields
		opts = {
			delay = 0,
			sort = { "desc" },
			icons = {
				-- set icon mappings to true if you have a Nerd Font
				mappings = vim.g.have_nerd_font,

				-- 自定义关键词图标
				rules = {
					{ pattern = "diag", icon = "󱖫 ", color = "green" },
					{ pattern = "doc", icon = " ", color = "orange" },
					{ pattern = "misc", icon = " ", color = "green" },
				},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>a", group = "avante" },
				{ "<leader>b", group = "buffer" },
				{ "<leader>c", group = "code", mode = { "n", "x" } },
				{ "<leader>d", group = "debug" },
				{ "<leader>s", group = "search" },
				{ "<leader>w", group = "workspace" },
				{ "<leader>e", group = "extract", mode = { "n", "v" } },
				{ "<leader>h", group = "hunk", mode = { "n", "v" } },
				{ "<leader>v", group = "venv" },
				{ "<leader>j", group = "jupyter" },
				{ "<leader>r", group = "rest", mode = { "n", "v" } },
				{ "<leader>m", group = "misc", mode = { "n", "v" } },
				{ "<leader>t", group = "test", mode = { "n", "v" } },
				-- { "<leader>h", group = "harpoon", mode = { "n", "v" } },
			},
		},
	},
	-- { -- 淡化非聚焦区域代码
	-- 	"folke/twilight.nvim",
	-- 	opts = {
	-- 		-- your configuration comes here
	-- 		-- or leave it empty to use the default settings
	-- 		-- refer to the configuration section below
	-- 	},
	-- },
	-- "voldikss/vim-translator", -- 国人写的翻译插件
	{ -- 弹窗翻译软件，暂时仅支持"yandex", "argos", "apertium", "google"且连不上或需要auth_key
		"potamides/pantran.nvim",
		config = function()
			local pantran = require("pantran")
			pantran.setup({ default_engine = "google" })

			local opts = { noremap = true, silent = true, expr = true, desc = "[t]ranslate" }
			-- vim.keymap.set("n", "<Leader>mt", pantran.motion_translate, opts)
			vim.keymap.set("n", "<leader>mt", function()
				return pantran.motion_translate() .. "_"
			end, opts)
			vim.keymap.set("x", "<leader>mt", pantran.motion_translate, opts)
		end,
	},
	-- {  --翻译软件，依赖于trans命令（translate-shell）
	-- 	"niuiic/translate.nvim",
	-- 	config = function()
	-- 		local function trans_to_zh()
	-- 			-- require("translate").translate({
	-- 			-- 	get_command = function(input)
	-- 			-- 		return {
	-- 			-- 			"trans",
	-- 			-- 			"-e",
	-- 			-- 			"bing",
	-- 			-- 			"-b",
	-- 			-- 			":zh",
	-- 			-- 			input,
	-- 			-- 		}
	-- 			-- 	end,
	-- 			-- 	-- input | clipboard | selection
	-- 			-- 	input = "selection",
	-- 			-- 	-- open_float | notify | copy | insert | replace
	-- 			-- 	output = { "open_float" },
	-- 			-- 	resolve_result = function(result)
	-- 			-- 		if result.code ~= 0 then
	-- 			-- 			return nil
	-- 			-- 		end
	-- 			--
	-- 			-- 		return string.match(result.stdout, "(.*)\n")
	-- 			-- 	end,
	-- 			-- })
	-- 		end
	--
	-- 		local function trans_to_en()
	-- 			require("translate").translate({
	-- 				get_command = function(input)
	-- 					return {
	-- 						"trans",
	-- 						"-e",
	-- 						"bing",
	-- 						"-b",
	-- 						":en",
	-- 						input,
	-- 					}
	-- 				end,
	-- 				input = "selection",
	-- 				output = { "replace" },
	-- 				resolve_result = function(result)
	-- 					if result.code ~= 0 then
	-- 						return nil
	-- 					end
	--
	-- 					return string.match(result.stdout, "(.*)\n")
	-- 				end,
	-- 			})
	-- 		end
	--
	-- 		local opts = { noremap = true, silent = true, expr = true }
	-- 		vim.keymap.set("n", "<Leader>te", trans_to_en, opts)
	-- 		vim.keymap.set("n", "<Leader>tz", trans_to_zh, opts)
	-- 	end,
	-- 	dependencies = { "niuiic/omega.nvim" },
	-- },

	"sindrets/diffview.nvim", -- 比较代码差异
	-- "ThePrimeagen/vim-be-good",
	-- { -- 按键优化提示
	-- 	"m4xshen/hardtime.nvim",
	-- 	dependencies = { "MunifTanjim/nui.nvim" },
	-- 	opts = {},
	-- 	event = "BufEnter",
	-- },
	{ -- 重构代码
		"ThePrimeagen/refactoring.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		-- lazy = false,
		opts = {},
	},
	-- { -- 快速切换文件（类似有grapple、arrow、dartboard、warp、booky、rabbit.nvim等）
	-- 	"ThePrimeagen/harpoon",
	-- 	branch = "harpoon2",
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- 	keys = {
	-- 		{
	-- 			"<leader>ha",
	-- 			function()
	-- 				require("harpoon"):list():add()
	-- 			end,
	-- 			desc = "harpoon: [a]dd",
	-- 		},
	-- 		{
	-- 			"<leader>hp",
	-- 			function()
	-- 				require("harpoon"):list():prev()
	-- 			end,
	-- 			desc = "harpoon: [p]rev",
	-- 		},
	-- 		{
	-- 			"<leader>hn",
	-- 			function()
	-- 				require("harpoon"):list():next()
	-- 			end,
	-- 			desc = "harpoon: [n]ext",
	-- 		},
	-- 		{
	-- 			"<leader>hl",
	-- 			function()
	-- 				harpoon = require("harpoon")
	-- 				harpoon.ui:toggle_quick_menu(harpoon:list())
	-- 			end,
	-- 			desc = "harpoon: [l]ist",
	-- 		},
	-- 	},
	-- 	config = function()
	-- 		require("harpoon").setup({
	-- 			settings = {
	-- 				save_on_toggle = true, -- 自动保存至内存
	-- 				sync_on_ui_close = true, -- 自动保存至文件系统
	-- 			},
	-- 		})
	--
	-- 		harpoon = require("harpoon")
	-- 		for i = 1, 9 do
	-- 			vim.keymap.set("n", "<leader>h" .. i, function()
	-- 				harpoon:list():select(i)
	-- 			end, { desc = "file " .. i })
	-- 		end
	-- 	end,
	-- },
	-- { -- 快速跳转文件
	-- 	"otavioschwanck/arrow.nvim",
	-- 	dependencies = {
	-- 		{ "nvim-tree/nvim-web-devicons" },
	-- 	},
	-- 	opts = {
	-- 		per_buffer_config = {
	-- 			lines = 3,
	-- 			satellite = { -- default to nil, display arrow index in scrollbar at every update
	-- 				enable = false,
	-- 				overlap = true,
	-- 				priority = 1000,
	-- 			},
	-- 		},
	-- 		show_icons = true,
	-- 		leader_key = "\\", -- Recommended to be a single key
	-- 		buffer_leader_key = "m", -- Per Buffer Mappings
	-- 	},
	-- },
	{ -- 自动切换f-strings
		"chrisgrieser/nvim-puppeteer",
		lazy = false, -- plugin lazy-loads itself.
	},
	-- { -- 简化复杂按键频繁输入（Emace hydra）
	-- 	"nvimtools/hydra.nvim",
	-- 	config = function()
	-- 		-- create hydras in here
	-- 	end,
	-- },
	{ -- 文件自动保存
		"okuuva/auto-save.nvim",
		-- version = "^1.0.0", -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
		cmd = "ASToggle", -- optional for lazy loading on command
		event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
		opts = {},
	},
	{ -- 可视化undo tree
		"jiaoshijie/undotree",
		lazy = true,
		opts = {},
		keys = { -- load the plugin only when using it's keybinding:
			{ "<leader>bu", "<cmd>lua require('undotree').toggle()<cr>", desc = "buffer: [u]ndo tree" },
		},
	},
	{ -- command-preview效果，比如Preview norm
		"smjonas/live-command.nvim",
		config = function()
			require("live-command").setup({
				commands = {
					Norm = { cmd = "norm" },
					G = { cmd = "g" },
				},
			})
		end,
	},
	-- { -- 变量改名preview效果
	-- 	"smjonas/inc-rename.nvim",
	-- 	config = function()
	-- 		require("inc_rename").setup()
	-- 	end,
	-- },
	-- { -- 切换buffer小浮窗
	-- 	"ghillb/cybu.nvim",
	-- 	dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
	-- 	config = function()
	-- 		require("cybu").setup()
	-- 	end,
	-- },
	{ -- buffer管理器
		"romgrk/barbar.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		opts = {
			animation = false,
			hide = { extensions = true },
			icons = {
				button = false,
				filetype = { custom_colors = true, enabled = false },
				-- 分隔符默认为▎，右边界设为空格，美化间隔
				separator = { right = " " },
				inactive = { separator = { right = " " } },
			},
			minimum_padding = 0,
			maximum_length = 14,
		},
	},
	-- { -- 自动清理未使用的buffer，确保数量在限定范围内
	-- 	"ChuufMaster/buffer-vacuum",
	-- 	opts = { max_buffers = 15 },
	-- },
	{ -- 自动关闭未插入或修改的buffer
		"axkirillov/hbac.nvim",
		config = true,
	},
	-- { --自动关闭不活跃buffer
	-- 	"chrisgrieser/nvim-early-retirement",
	-- 	event = "VeryLazy",
	-- 	opts = {
	-- 		retirementAgeMins = 20,
	-- 		minimumBufferNum = 8,
	-- 	},
	-- },
	-- { -- 切换buffer
	-- 	"voxelprismatic/rabbit.nvim",
	-- 	branch = "rewrite",
	-- 	lazy = false,
	--
	-- 	---@type Rabbit.Config
	-- 	opts = {},
	-- 	config = true,
	-- },
	-- { -- 缓冲区列表
	-- 	"EL-MASTOR/bufferlist.nvim",
	-- 	lazy = true,
	-- 	keys = { { "<Leader>bl", ":BufferList<CR>", desc = "buffer: [l]ist" } },
	-- 	dependencies = "nvim-tree/nvim-web-devicons",
	-- 	cmd = "BufferList",
	-- 	opts = {},
	-- },
	-- { --缓冲区管理
	-- 	-- "mong8se/buffish.nvim",
	-- 	"j-morano/buffer_manager.nvim",
	-- 	config = function()
	-- 		require("buffer_manager").setup({
	-- 			short_file_names = true,
	-- 			order_buffers = "filename",
	-- 		})
	-- 	end,
	-- },
	{ -- 快速切换buffer
		"ilovevim/buffer-sticks.nvim",
		event = "VeryLazy",
		keys = {
			{
				"\\",
				function()
					BufferSticks.jump()
				end,
				desc = "Jump to buffer",
			},
		},
		config = function()
			local sticks = require("buffer-sticks")
			sticks.setup({
				show_indicators = false,
				position = "center",
				active_char = "──",
				inactive_char = "─",
				alternate_char = "─",
				filter = { buftypes = { "terminal" } },
				list = {
					show = { "label", "filename" },
					sort = { field = "label" },
					align = {
						label = "right",
						filename = "left",
					},
					separator = " ",
				},
				preview = {
					enabled = false,
				},
				highlights = {
					active = { link = "Statement" },
					alternate = { link = "StorageClass" },
					inactive = { fg = "#ADADAD" },
					active_modified = { link = "Constant" },
					alternate_modified = { link = "Constant" },
					inactive_modified = { link = "Constant" },
					label = { link = "ErrorMsg" },
					filter_selected = { link = "Statement" },
					filter_title = { link = "Comment" },
					list_selected = { link = "Statement" },
				},
			})
			sticks.show()
		end,
	},
	-- { -- 切分代码行/汇总代码块：未比mini.splitjoin更好
	-- 	"Wansmer/treesj",
	-- 	keys = { "<space>m", "<space>j", "<space>s" },
	-- 	dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
	-- 	config = function()
	-- 		require("treesj").setup({--[[ your config ]]
	-- 		})
	-- 	end,
	-- },
	{ -- 自动添加结尾标签
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
	-- { -- 浮窗解释regex正则表达式
	-- 	"bennypowers/nvim-regexplainer",
	-- 	dependencies = {
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 		"MunifTanjim/nui.nvim",
	-- 	},
	-- 	config = function()
	-- 		require("regexplainer").setup()
	-- 	end,
	-- },
	-- { -- 正则表达式解释
	-- 	"tomiis4/Hypersonic.nvim",
	-- 	event = "CmdlineEnter",
	-- 	cmd = "Hypersonic",
	-- 	config = function()
	-- 		require("hypersonic").setup({})
	-- 	end,
	-- },
	{ -- 提取url清单
		"axieax/urlview.nvim",
		opts = {},
	},
	-- { -- 平滑滚动（使用neovim原生滚动效果更好）
	-- 	"karb94/neoscroll.nvim",
	-- 	opts = {},
	-- },
	{ -- 函数上下文提示
		"andersevenrud/nvim_context_vt",
		opts = {
			enabled = false,
		},
	},
	{ -- 切换日期、布尔值等
		"nat-418/boole.nvim",
		opts = {
			mappings = {
				increment = "<C-a>",
				decrement = "<C-x>",
			},
			-- User defined loops
			additions = {
				{ "Foo", "Bar" },
				{ "tic", "tac", "toe" },
			},
			allow_caps_additions = {
				{ "enable", "disable" },
			},
		},
	},
	{ -- ts节点动作：折行（可取代splitjoin）、切换值
		"ckolkey/ts-node-action",
		opts = {},
		keys = {
			{ "gs", "<cmd>NodeAction<cr>", mode = "n", desc = "ts-node-action" },
		},
	},
	{ -- 屏幕显示按键
		"NStefan002/screenkey.nvim",
		lazy = false,
		version = "*", -- or branch = "main", to use the latest commit
	},
	-- 颜色主题，部分插件关闭注释斜体在options.lua中设置
	{ "folke/tokyonight.nvim", lazy = true, opts = { styles = { comments = { italic = false } } } },
	{ "HoNamDuong/hybrid.nvim", lazy = true, opts = { italic = { comments = false } } },
	-- 'navarasu/onedark.nvim',
	{ "olimorris/onedarkpro.nvim", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true, opts = { commentStyle = { italic = false } } },
	{ "sainnhe/sonokai", lazy = true },
	-- {"ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ..., lazy = true},
	{ "sainnhe/gruvbox-material", lazy = true },
	{ "EdenEast/nightfox.nvim", lazy = true },
	{ "sainnhe/everforest", lazy = true },
	{ "Mofiqul/vscode.nvim", lazy = true },
	-- { "yashguptaz/calvera-dark.nvim", lazy = true },
	{ "projekt0n/github-nvim-theme", name = "github-theme" },
	{ "NLKNguyen/papercolor-theme", lazy = true },
	-- { "nanotech/jellybeans.vim", lazy = true },
	{ "gremble0/yellowbeans.nvim", lazy = true },
	-- { "tomasr/molokai", lazy = true },
	{ "loctvl842/monokai-pro.nvim", lazy = true },
	-- { "nordtheme/vim", lazy = true },
	{ "rakr/vim-one", lazy = true },
	-- { "ayu-theme/ayu-vim", lazy = true },
	-- { "nyoom-engineering/oxocarbon.nvim", lazy = true },
	{ "rmehri01/onenord.nvim", lazy = true },
	-- { "calind/selenized.nvim", lazy = true },
	{ "xero/miasma.nvim", lazy = true },
	-- { "mhartington/oceanic-next", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	-- { "miikanissi/modus-themes.nvim", priority = 1000 },
	{ "Mofiqul/dracula.nvim", lazy = true },
	{ "glepnir/zephyr-nvim", lazy = true },
	{ "JoosepAlviste/palenightfall.nvim", lazy = true },
	{ "savq/melange-nvim", lazy = true },
	{ "uloco/bluloco.nvim", lazy = false, dependencies = { "rktjmp/lush.nvim" } },
	{
		"rose-pine/neovim",
		lazy = true,
		config = function()
			require("rose-pine").setup({ styles = { italic = false } })
		end,
	},
	{ "ilof2/posterpole.nvim", lazy = true },
	-- { "scottmckendry/cyberdream.nvim", lazy = true },
	-- { -- neosolarized
	-- 	"svrana/neosolarized.nvim",
	-- 	lazy = true,
	-- 	dependencies = {
	-- 		"tjdevries/colorbuddy.nvim",
	-- 	},
	-- 	opts = {
	-- 		comment_italics = false,
	-- 	},
	-- },

	-- 批量导入配置文件
	-- { import = "core" },

	-- 其他插件（来自于kickstart）
	require("plug.debug"),
	-- require("plug.lint"),
	require("plug.gitsigns"), -- adds gitsigns recommend keymaps

	-- 用mini.indentscope替代
	-- require("plug.indent_line"),
}

local opts = {
	rocks = {
		enabled = false, -- 完全禁用 luarocks 依赖
		-- hererocks = true, -- 可选，但不必须
	},
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
} -- 注意要定义这个变量

-- lazy设置
require("lazy").setup(plugins, opts)

-- 系统设置
require("core.options")
require("core.keymaps")
require("core.themes")
require("core.toggleime")

-- 其他插件
-- require("plug.autopairs")
require("plug.toggleterm")
require("plug.filetype")
-- require("plug.bufferline")
