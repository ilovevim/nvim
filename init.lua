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
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- 插件配置
local plugins = {
	--"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	-- { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },
	{ -- bufferline、lualine可mini相关套件替换
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
		config = function()
			require("lualine").setup({
				options = {
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
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
						-- { -- fittencode插件状态
						-- 	function()
						-- 		local emoji = { "🚫", "⏸️ ", "⌛️", "⚠️ ", "0️⃣ ", "✅" }
						-- 		return "🅕 " .. emoji[require("fittencode").get_current_status()]
						-- 	end,
						-- },
						"encoding",
						"filetype",
					},
				},
			})
		end,
	}, -- 状态栏

	{ -- 文档树
		"nvim-tree/nvim-tree.lua",
		config = function()
			-- disable netrw
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			require("nvim-tree").setup({
				view = {
					width = 25,
				},
				-- update_focused_file = {
				-- 	enable = true,
				-- 	update_root = {
				-- 		enable = true,
				-- 	},
				-- },
			})
		end,
	},
	"nvim-tree/nvim-web-devicons", -- 文档树图标

	"christoomey/vim-tmux-navigator", -- 用ctl-hjkl来定位窗口

	-- "nvim-treesitter/nvim-treesitter-context", -- 当前上下文，改用navic等面包屑插件
	-- "nvim-treesitter/nvim-treesitter-textobjects", -- 有flash后作用不大！
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		-- dependencies = {
		-- 	"nvim-treesitter/nvim-treesitter-textobjects", -- 有flash后作用不大！
		-- },
		-- main = "nvim-treesitter.configs", -- Sets main module to use for opts
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
		-- opts = {
		config = function()
			local treesitter = require("nvim-treesitter.configs")

			-- configure treesitter
			---@diagnostic disable-next-line: missing-fields
			treesitter.setup({
				ensure_installed = {
					"json",
					"javascript",
					"yaml",
					"html",
					"bash",
					"c",
					"diff",
					"html",
					"lua",
					"luadoc",
					"markdown",
					"markdown_inline",
					"query",
					"vim",
					"vimdoc",
				},
				-- Autoinstall languages that are not installed
				auto_install = true,
				highlight = {
					enable = true,
					-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
					--  If you are experiencing weird indenting issues, add the language to
					--  the list of additional_vim_regex_highlighting and disabled languages for indent.
					additional_vim_regex_highlighting = { "ruby" },
				},
				indent = { enable = true, disable = { "ruby" } },

				-- 不同括号颜色区分
				rainbow = {
					enable = true,
					-- extended_mode = true,
					-- max_file_lines = nil,
				},

				-- There are additional nvim-treesitter modules that you can use to interact
				-- with nvim-treesitter. You should go explore a few and see what interests you:
				--
				--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
				--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
				--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
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
	{ -- Main LSP Configuration
		"neovim/nvim-lspconfig",
		-- event = "VeryLazy",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "williamboman/mason.nvim", cmd = "Mason", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ -- 进度提示
				"j-hui/fidget.nvim",
				opts = {
					notification = {
						-- 等价于vim.notify = require("fidget.notification").notify
						-- override_vim_notify = true,
					},
				},
			},

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
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
					map("gy", require("telescope.builtin").lsp_type_definitions, "goto t[y]pe definition")

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
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>ct", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "code: [t]oggle hint")
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
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

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
				-- clangd = {},
				-- gopls = {},

				-- pyright侧重于类型检查，ruff负责lint、import、快速修复
				-- https://microsoft.github.io/pyright/#/settings
				pyright = {
					settings = {
						-- pyright = {
						-- 			-- disableLanguageServices = false, -- 保持基础 LSP 功能
						-- 			disableOrganizeImports = true, -- 关闭 Pyright 自带的 import 整理
						-- 		},
						python = {
							analysis = {
								extraPaths = { "." },
								-- 				-- useLibraryCodeForTypes = true,
								-- 				-- diagnosticSeverityOverrides = {
								-- 				-- 	reportUnusedImport = "none", -- 禁用未使用导入的提示
								-- 				-- },
								-- 				-- autoImportCompletions = true,
								-- 				-- typeCheckingMode = "strict",
								-- 				-- diagnosticMode = "workspace", -- 降低实时诊断频率
								-- 				linting = { enabled = false }, -- 彻底关闭 Pyright 的 lint 功能
								--
								-- 				-- Ignore all files for analysis to exclusively use Ruff for linting
								-- 				-- ignore = { "*" },
							},
						},
					},
				},

				-- https://docs.astral.sh/ruff/editors/settings/
				-- ruff = {
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
				-- },

				-- rust_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--

				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							-- workspace = {checkThirtyParty = false},
							hint = { enable = true },
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
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
			}

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
				"lua_ls",
				"pyright",
				"ruff",
				-- "jdtls",
			})

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						vim.notify("checking server", server_name, server)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

						-- Mason中安装的LSP会逐个进入，为避免jdtls被二次启动此处跳过，改为在nvim-jdtls插件中配置
						if server_name ~= "jdtls" then
							require("lspconfig")[server_name].setup(server)
						end
					end,
				},
			})
		end,
	},

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
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
			},
			"saadparwaiz1/cmp_luasnip",

			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			-- "f3fora/cmp-spell", -- 拼写提示，中文注释也显示spell红色波浪线
			{ -- nvim-dbee补全插件
				"MattiasMTS/cmp-dbee",
				dependencies = {
					{ "kndndrj/nvim-dbee" },
				},
				ft = "sql", -- optional but good to have
				opts = {}, -- needed
			},

			"onsails/lspkind-nvim", -- 自动补全分类小图标
		},
		config = function()
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert({
					-- Select the [n]ext item
					["<C-n>"] = cmp.mapping.select_next_item(),
					-- Select the [p]revious item
					["<C-p>"] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Accept (<c-y>[y]es) the completion.
					-- Accept multi-line completion
					["<c-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),

					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					["<CR>"] = cmp.mapping.confirm({ select = true }),

					-- If you prefer more traditional completion keymaps,
					-- you can uncomment the following lines
					--['<CR>'] = cmp.mapping.confirm { select = true },
					--['<Tab>'] = cmp.mapping.select_next_item(),
					--['<S-Tab>'] = cmp.mapping.select_prev_item(),

					-- Manually trigger a completion from nvim-cmp.
					--  Generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					-- ["<C-Space>"] = cmp.mapping.complete({}),
					["<C-2>"] = cmp.mapping.complete({}),

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					-- ["<C-h>"] = cmp.mapping(function()
					-- 	if luasnip.locally_jumpable(-1) then
					-- 		luasnip.jump(-1)
					-- 	end
					-- end, { "i", "s" }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				}),
				sources = {
					-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
					{ name = "lazydev", group_index = 0 },
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
					{
						name = "buffer",
						option = {
							-- 扫描所有打开的Buffer（默认仅当前Buffer）
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
							end,
							-- 调整符号匹配规则（如允许下划线）
							keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
						},
					},
					{ name = "path" },
					{ name = "cmp-dbee" },
					{ name = "fittencode", group_index = 1 },
					-- { name = "codeium" },
					-- { name = "cmp_tabnine" },
					-- 黑白色，没有lsp_signature彩色效果
					-- { name = "nvim_lsp_signature_help" },
					-- { -- 拼写检查
					-- 	name = "spell",
					-- 	option = {
					-- 		keep_all_entries = false,
					-- 		enable_in_context = function()
					-- 			return true
					-- 		end,
					-- 		preselect_correct_word = true,
					-- 	},
					-- },
				},
				-- 使用lspkind-nvim显示类型图标
				---@diagnostic disable-next-line: missing-fields
				formatting = {
					format = require("lspkind").cmp_format({
						with_text = true, -- do not show text alongside icons
						maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						before = function(entry, vim_item)
							-- Source 显示提示来源
							-- vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"

							-- 只取最后一个"_"后面子串，比如cmp_buffer取后缀buffer
							vim_item.menu = "[" .. string.gsub(entry.source.name, "(%w+)_", "") .. "]"
							return vim_item
						end,
					}),
				},
			})

			-- -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				---@diagnostic disable-next-line: missing-fields
				matching = { disallow_symbol_nonprefix_matching = false },
			})
		end,
	},

	-- { -- 写代码AI辅助
	-- 	"tzachar/cmp-tabnine",
	-- 	event = "InsertEnter",
	-- 	build = "powershell ./install.ps1",
	-- 	dependencies = "hrsh7th/nvim-cmp",
	-- },
	{ -- AI辅助
		"luozhiya/fittencode.nvim",
		event = "VeryLazy",
		config = function()
			require("fittencode").setup({
				completion_mode = "source",
			})
		end,
	},
	{ -- 类似CursorIDE的AI插件
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- set this if you want to always pull the latest change
		opts = {
			provider = "openai",
			auto_suggestions_provider = "openai", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
			openai = {
				endpoint = "https://api.deepseek.com/v1",
				model = "deepseek-chat",
				timeout = 30000, -- Timeout in milliseconds
				temperature = 0,
				max_tokens = 4096,
				-- optional
				api_key_name = "OPENAI_API_KEY", -- default OPENAI_API_KEY if not set
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		-- build = "make",
		build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false", -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			-- "stevearc/dressing.nvim",
			-- "folke/snacks.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
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
	{ -- 函数签名提醒
		"ray-x/lsp_signature.nvim",
		-- event = "VeryLazy",
		opts = {
			bind = true,
			handler_opts = {
				border = "rounded",
			},
		},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},

	--其他lsp服务

	-- { -- pyright专用自动import工具，不好用！
	-- 	"stevanmilic/nvim-lspimport",
	-- 	lazy = true,
	-- 	ft = "python",
	-- },
	-- { --pymple.nvim需要安装gg和sed工具
	-- 	-- PympleBuild安装报错，可以采用cargo手工安装
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
	-- 		require("pymple").setup()
	-- 	end,
	-- },
	{ -- 集成到telescope中的import工具
		"ilovevim/telescope-import.nvim",
		dependencies = "nvim-telescope/telescope.nvim",
		config = function()
			require("telescope").load_extension("import")
		end,
		keys = {
			{
				"<leader>ci",
				-- ":Telescope import<cr><c-r><c-w>", -- 底层不接受传参（比如当前位置单词）
				"<cmd>Telescope import<cr>",
				mode = "n",
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
	-- 	"kristijanhusak/vim-dadbod-ui",  -- 实测不好用
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
		keys = {
			{ "<leader>Rs", desc = "Send request" },
			{ "<leader>Ra", desc = "Send all requests" },
			{ "<leader>Rb", desc = "Open scratchpad" },
		},
		ft = { "http", "rest" },
		opts = {
			-- your configuration comes here
			global_keymaps = true,
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
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ "nvim-dap-ui" },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	"kosayoda/nvim-lightbulb", -- code action提示灯泡
	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		-- event = "VeryLazy",
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "code: [f]ormat",
			},
		},
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
			format_on_save = { timeout_ms = 500 },
			-- Customize formatters
			formatters = {
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
		event = "VeryLazy",
		opts = {
			-- lsp = { auto_attach = true },
			depth_limit = 2,
		},
		dependencies = { "neovim/nvim-lspconfig" },
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
		event = "VeryLazy",
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
	{ -- 自动补全括号
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	{ -- mini插件Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
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

			-- tabline插件
			require("mini.tabline").setup({ tabpage_section = "none" })

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

			-- 操作符保留默认的exchange和sort，分别对应gx和gs快捷键，其余弃用
			require("mini.operators").setup({
				evaluate = { prefix = "" }, -- 默认为g=
				multiply = { prefix = "" }, -- 默认为gm
				replace = { prefix = "" }, -- 默认为gr
				sort = { prefix = "" }, -- 默认为gs
			})

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

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
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
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			-- "ibhagwan/fzf-lua",              -- optional
			-- "echasnovski/mini.pick",         -- optional
		},
		config = true,
	},
	{ -- telescope, Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
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
					layout_strategy = "vertical",
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
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			-- 集成nvim-notify控件，可执行:Telescope notify
			pcall(require("telescope").load_extension, "notify")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>dw", builtin.diagnostics, { desc = "diag: [w]orkspace" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "search: [f]ile" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "search: [g]rep" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "search: [h]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "search: [k]eymap" })
			vim.keymap.set("n", "<leader>so", builtin.oldfiles, { desc = "search: [o]ld file" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "search: [r]esume" })
			vim.keymap.set("n", "<leader>ss", builtin.grep_string, { desc = "search: [s]tring" })
			vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "search: [t]elescope" })
			vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "search: [b]uffer" })

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
		end,
	},
	{ -- flash闪电移动
		"folke/flash.nvim", -- 闪电移动跳转
		event = "VeryLazy",
		---@type Flash.Config
		opts = {}, -- labels = "asdfghjklqwertyuiopzxcvbnm;,0123456789[]./'\\" },
        -- stylua: ignore
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
            { "gl", mode = { "n"}, function() require("flash").jump(
                ---@diagnostic disable-next-line: missing-fields
                {
                    search = { mode = "search", max_length = 0 },
                    label = { after = { 0, 0 } },
                    pattern = "^",
                }
            ) end, desc = "Flash: Jump to line start" },
            { "gl", mode = { "x", "o" }, function() require("flash").jump(
                ---@diagnostic disable-next-line: missing-fields
                {
                    search = { mode = "search", max_length = 0 },
                    pattern = "$",
                }
            ) end, desc = "Flash: Jump to line end" },
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
	{ -- FIX 测试框架，暂无法正常使用
		"nvim-neotest/neotest",
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
		opts = { use_colorpalette = true, sequential_colorpalette = true }, -- needed
	},
	{ -- 切换python虚拟环境
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"mfussenegger/nvim-dap",
			"mfussenegger/nvim-dap-python", --optional
			{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
		},
		lazy = false,
		branch = "regexp", -- This is the regexp branch, use this for the new version
		config = function()
			require("venv-selector").setup()
		end,
		keys = {
			-- Keymap to open VenvSelector to pick a venv.
			{ "<leader>vs", "<cmd>VenvSelect<cr>" },
			-- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
			{ "<leader>vc", "<cmd>VenvSelectCached<cr>" },
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
			{ "<leader>wo", "<cmd>SessionSearch<CR>", desc = "session: [o]pen" },
			{ "<leader>ws", "<cmd>SessionSave<CR>", desc = "session: [s]ave" },
			{ "<leader>wt", "<cmd>SessionToggleAutoSave<CR>", desc = "session: [t]oggle save" },
		},
		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			-- log_level = 'debug',
			auto_restore = false,
			auto_create = false,
		},
	},

	{ -- 除了nvim-notify之外，vim.notify可以采用fidget、mini.notify
		"rcarriga/nvim-notify",
		opts = {
			-- #134问题：https://github.com/rcarriga/nvim-notify/issues/134
			background_colour = "#1a1b26",
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
			presets = {
				inc_rename = true,
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
		event = "VeryLazy",
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
		opts = {
			icons = {
				-- set icon mappings to true if you have a Nerd Font
				mappings = vim.g.have_nerd_font,
				-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
				-- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>a", group = "[a]vante" },
				{ "<leader>c", group = "[c]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[d]ebug" },
				{ "<leader>s", group = "[s]earch" },
				{ "<leader>w", group = "[w]orkspace" },
				{ "<leader>e", group = "[e]xtract", mode = { "n", "v" } },
				{ "<leader>h", group = "[h]unk", mode = { "n", "v" } },
				{ "<leader>r", group = "[r]est", mode = { "n", "v" } },
				{ "<leader>v", group = "[v]env" },
				{ "<leader>j", group = "[j]upyter" },
				{ "<leader>R", group = "[R]est" },
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
	"voldikss/vim-translator", -- 国人写的翻译插件
	{ -- 文件自动保存
		"okuuva/auto-save.nvim",
		-- version = "^1.0.0", -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
		cmd = "ASToggle", -- optional for lazy loading on command
		event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
		opts = {},
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
	{ -- 变量改名preview效果
		"smjonas/inc-rename.nvim",
		config = function()
			require("inc_rename").setup()
		end,
	},
	-- { -- 切换buffer小浮窗
	-- 	"ghillb/cybu.nvim",
	-- 	dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
	-- 	config = function()
	-- 		require("cybu").setup()
	-- 	end,
	-- },
	{ -- 自动清理未使用的buffer，确保数量在限定范围内
		"ChuufMaster/buffer-vacuum",
		opts = { max_buffers = 7 },
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
	{ -- 正则表达式解释
		"tomiis4/Hypersonic.nvim",
		event = "CmdlineEnter",
		cmd = "Hypersonic",
		config = function()
			require("hypersonic").setup({})
		end,
	},
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
	-- 颜色主题，部分插件关闭注释斜体在options.lua中设置
	{
		"folke/tokyonight.nvim",
		lazy = true,
		opts = {
			styles = {
				comments = { italic = false },
			},
		},
	},
	{ "HoNamDuong/hybrid.nvim", lazy = true, opts = {
		italic = { comments = false },
	} },
	-- 'navarasu/onedark.nvim',
	{ "olimorris/onedarkpro.nvim", lazy = true },
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
		opts = {
			commentStyle = {
				italic = false,
			},
		},
	},
	{ "sainnhe/sonokai", lazy = true },
	-- {"ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ..., lazy = true},
	{ "sainnhe/gruvbox-material", lazy = true },
	{ "EdenEast/nightfox.nvim", lazy = true },
	{ "sainnhe/everforest", lazy = true },
	{ "Mofiqul/vscode.nvim", lazy = true },
	-- { "yashguptaz/calvera-dark.nvim", lazy = true },
	{ "projekt0n/github-nvim-theme", name = "github-theme" },
	{ "NLKNguyen/papercolor-theme", lazy = true },
	{ "nanotech/jellybeans.vim", lazy = true },
	-- { "tomasr/molokai", lazy = true },
	{ "loctvl842/monokai-pro.nvim", lazy = true },
	-- { "nordtheme/vim", lazy = true },
	{ "rakr/vim-one", lazy = true },
	{ "ayu-theme/ayu-vim", lazy = true },
	{ "nyoom-engineering/oxocarbon.nvim", lazy = true },
	{ "rmehri01/onenord.nvim", lazy = true },
	-- { "calind/selenized.nvim", lazy = true },
	{ "xero/miasma.nvim", lazy = true },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = true,
		opts = {
			-- no_italic = true,
			styles = {
				comments = {},
			},
		},
	},
	{
		"rose-pine/neovim",
		lazy = true,
		config = function()
			require("rose-pine").setup({
				styles = {
					bold = false,
					italic = false,
				},
			})
		end,
	},
	{ -- neosolarized
		"svrana/neosolarized.nvim",
		lazy = true,
		dependencies = {
			"tjdevries/colorbuddy.nvim",
		},
		opts = {
			comment_italics = false,
		},
	},

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
require("plug.autopairs")
require("plug.toggleterm")
require("plug.filetype")
-- require("plug.bufferline")
