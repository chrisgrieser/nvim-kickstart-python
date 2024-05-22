-- BOOTSTRAP the plugin manager `lazy.nvim`
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim"
	vim.system({ "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath }):wait()
end
vim.opt.runtimepath:prepend(lazypath)

--------------------------------------------------------------------------------
-- BASIC PYTHON-RELATED OPTIONS

-- The filetype-autocmd runs a function when opening a file with the filetype
-- "python". This method allows you to make filetype-specific configurations. In
-- there, you have to use `opt_local` instead of `opt` to limit the changes to
-- just that buffer. (As an alternative to using an autocmd, you can also put those
-- configurations into a file `/after/ftplugin/{filetype}.lua` in your
-- nvim-directory.)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python", -- filetype for which to run the autocmd
	callback = function()
		-- use pep8 standards
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4

		-- folds based on indentation https://neovim.io/doc/user/fold.html#fold-indent
		-- if you are a heavy user of folds, consider using `nvim-ufo`
		vim.opt_local.foldmethod = "indent"

		local iabbrev = function(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end
		-- automatically capitalize boolean values. Useful if you come from a
		-- different language, and lowercase them out of habit.
		iabbrev("true", "True")
		iabbrev("false", "False")

		-- in the same way, we can fix habits regarding comments or None
		iabbrev("--", "#")
		iabbrev("null", "None")
		iabbrev("none", "None")
		iabbrev("nil", "None")
	end,
})

--------------------------------------------------------------------------------

local plugins = {
	-- TOOLING: COMPLETION, DIAGNOSTICS, FORMATTING

	-- Manager for external tools (LSPs, linters, debuggers, formatters)
	-- auto-install of those external tools
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			{ "williamboman/mason.nvim", opts = true },
			{ "williamboman/mason-lspconfig.nvim", opts = true },
		},
		opts = {
			ensure_installed = {
				"pyright", -- LSP for python
				"ruff-lsp", -- linter for python (includes flake8, pep8, etc.)
				"debugpy", -- debugger
				"black", -- formatter
				"isort", -- organize imports
				"taplo", -- LSP for toml (for pyproject.toml files)
			},
		},
	},

	-- Setup the LSPs
	-- `gd` and `gr` for goto definition / references
	-- `<leader>c` for code actions (organize imports, etc.)
	{
		"neovim/nvim-lspconfig",
		keys = {
			{ "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
			{ "gr", vim.lsp.buf.references, desc = "Goto References" },
			{ "<leader>c", vim.lsp.buf.code_action, desc = "Code Action" },
		},
		init = function()
			-- this snippet enables auto-completion
			local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
			lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

			-- setup pyright with completion capabilities
			require("lspconfig").pyright.setup({
				capabilities = lspCapabilities,
			})

			-- setup taplo with completion capabilities
			require("lspconfig").taplo.setup({
				capabilities = lspCapabilities,
			})

			-- ruff uses an LSP proxy, therefore it needs to be enabled as if it
			-- were a LSP. In practice, ruff only provides linter-like diagnostics
			-- and some code actions, and is not a full LSP yet.
			require("lspconfig").ruff_lsp.setup({
				-- organize imports disabled, since we are already using `isort` for that
				-- alternative, this can be enabled to make `organize imports`
				-- available as code action
				settings = {
					organizeImports = false,
				},
				-- disable ruff as hover provider to avoid conflicts with pyright
				on_attach = function(client) client.server_capabilities.hoverProvider = false end,
			})
		end,
	},

	-- Formatting client: conform.nvim
	-- - configured to use black & isort in python
	-- - use the taplo-LSP for formatting in toml
	-- - Formatting is triggered via `<leader>f`, but also automatically on save
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- load the plugin before saving
		keys = {
			{
				"<leader>f",
				function() require("conform").format({ lsp_fallback = true }) end,
				desc = "Format",
			},
		},
		opts = {
			formatters_by_ft = {
				-- first use isort and then black
				python = { "isort", "black" },
				-- "inject" is a special formatter from conform.nvim, which
				-- formats treesitter-injected code. Basically, this makes
				-- conform.nvim format python codeblocks inside a markdown file.
				markdown = { "inject" },
			},
			-- enable format-on-save
			format_on_save = {
				-- when no formatter is setup for a filetype, fallback to formatting
				-- via the LSP. This is relevant e.g. for taplo (toml LSP), where the
				-- LSP can handle the formatting for us
				lsp_fallback = true,
			},
		},
	},

	-- Completion via nvim-cmp
	-- - Confirm a completion with `<CR>` (Return)
	-- - select an item with `<Tab>`/`<S-Tab>`
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- use suggestions from the LSP

			-- Snippet engine. Required for nvim-cmp to work, even if you don't
			-- intend to use custom snippets.
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- adapter for the snippet engine
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				-- tell cmp to use Luasnip as our snippet engine
				snippet = {
					expand = function(args) require("luasnip").lsp_expand(args.body) end,
				},
				-- Define the mappings for the completion. The `fallback()` call
				-- ensures that when there is no suggestion window open, the mapping
				-- falls back to the default behavior (adding indentation).
				mappings = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- true = autoselect first entry
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
			})
		end,
	},

	-----------------------------------------------------------------------------
	-- PYTHON REPL
	-- A basic REPL that opens up as a horizontal split
	-- - use `<leader>i` to toggle the REPL
	-- - use `<leader>I` to restart the REPL
	-- - `+` serves as the "send to REPL" operator. That means we can use `++`
	-- to send the current line to the REPL, and `+j` to send the current and the
	-- following line to the REPL, like we would do with other vim operators.
	{
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>i", vim.cmd.IronRepl, desc = "󱠤 Toggle REPL" },
			{ "<leader>I", vim.cmd.IronRestart, desc = "󱠤 Restart REPL" },

			-- these keymaps need no right-hand-side, since that is defined by the
			-- plugin config further below
			{ "+", mode = { "n", "x" }, desc = "󱠤 Send-to-REPL Operator" },
			{ "++", desc = "󱠤 Send Line to REPL" },
		},

		-- since irons's setup call is `require("iron.core").setup`, instead of
		-- `require("iron").setup` like other plugins would do, we need to tell
		-- lazy.nvim which module to via the `main` key
		main = "iron.core",

		opts = {
			keymaps = {
				send_line = "++",
				visual_send = "+",
				send_motion = "+",
			},
			config = {
				-- this defined how the repl is opened. Here we set the REPL window
				-- to open in a horizontal split to a bottom, with a height of 10
				-- cells.
				repl_open_cmd = "horizontal bot 10 split",

				-- This defines which binary to use for the REPL. If `ipython` is
				-- available, it will use `ipython`, otherwise it will use `python3`.
				-- since the python repl does not play well with indents, it's
				-- preferable to use `ipython` or `bypython` here.
				-- (see: https://github.com/Vigemus/iron.nvim/issues/348)
				repl_definition = {
					python = {
						command = function()
							local ipythonAvailable = vim.fn.executable("ipython") == 1
							local binary = ipythonAvailable and "ipython" or "python3"
							return { binary }
						end,
					},
				},
			},
		},
	},

	-----------------------------------------------------------------------------
	-- SYNTAX HIGHLIGHTING & COLORSCHEME

	-- treesitter for syntax highlighting
	-- - auto-installs the parser for python
	{
		"nvim-treesitter/nvim-treesitter",
		-- automatically update the parsers with every new release of treesitter
		build = ":TSUpdate",

		-- since treesitter's setup call is `require("nvim-treesitter.configs").setup`,
		-- instead of `require("nvim-treesitter").setup` like other plugins do, we
		-- need to tell lazy.nvim which module to via the `main` key
		main = "nvim-treesitter.configs",

		opts = {
			highlight = { enable = true }, -- enable treesitter syntax highlighting
			indent = { enable = true }, -- better indentation behavior
			ensure_installed = {
				-- auto-install the Treesitter parser for python and related languages
				"python",
				"toml",
				"rst",
				"ninja",
				-- needed for formatting code-blocks inside markdown via conform.nvim
				"markdown",
				"markdown_inline",
			},
		},
	},

	-- semshi for additional syntax highlighting.
	-- See the README for Treesitter cs Semshi comparison.
	-- requires `pynvim` (`python3 -m pip install pynvim`)
	{
		"wookayin/semshi", -- maintained fork
		ft = "python",
		build = ":UpdateRemotePlugins", -- don't disable `rplugin` in lazy.nvim for this
		init = function()
			vim.g.python3_host_prog = vim.fn.exepath("python3")
			-- better done by LSP
			vim.g["semshi#error_sign"] = false
			vim.g["semshi#simplify_markup"] = false
			vim.g["semshi#mark_selected_nodes"] = false
			vim.g["semshi#update_delay_factor"] = 0.001

			vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
				callback = function()
					vim.cmd([[
						highlight! semshiGlobal gui=italic
						highlight! link semshiImported @lsp.type.namespace
						highlight! link semshiParameter @lsp.type.parameter
						highlight! link semshiParameterUnused DiagnosticUnnecessary
						highlight! link semshiBuiltin @function.builtin
						highlight! link semshiAttribute @field
						highlight! link semshiSelf @lsp.type.selfKeyword
						highlight! link semshiUnresolved @lsp.type.unresolvedReference
						highlight! link semshiFree @comment
					]])
				end,
			})
		end,
	},

	-- Colorscheme
	-- In neovim, the choice of color schemes is unfortunately not purely
	-- aesthetic – treesitter-based highlighting or newer features like semantic
	-- highlighting are not always supported by a color scheme. It's therefore
	-- recommended to use one of the popular, and actively maintained ones to get
	-- the best syntax highlighting experience:
	-- https://dotfyle.com/neovim/colorscheme/top
	{
		"folke/tokyonight.nvim",
		-- ensure that the color scheme is loaded at the very beginning
		lazy = false,
		priority = 1000,
		-- enable the colorscheme
		config = function() vim.cmd.colorscheme("tokyonight") end,
	},

	-----------------------------------------------------------------------------
	-- DEBUGGING

	-- DAP Client for nvim
	-- - start the debugger with `<leader>dc`
	-- - add breakpoints with `<leader>db`
	-- - terminate the debugger `<leader>dt`
	{
		"mfussenegger/nvim-dap",
		keys = {
			{
				"<leader>dc",
				function() require("dap").continue() end,
				desc = "Start/Continue Debugger",
			},
			{
				"<leader>db",
				function() require("dap").toggle_breakpoint() end,
				desc = "Add Breakpoint",
			},
			{
				"<leader>dt",
				function() require("dap").terminate() end,
				desc = "Terminate Debugger",
			},
		},
	},

	-- UI for the debugger
	-- - the debugger UI is also automatically opened when starting/stopping the debugger
	-- - toggle debugger UI manually with `<leader>du`
	{
		"rcarriga/nvim-dap-ui",
		dependencies = "mfussenegger/nvim-dap",
		keys = {
			{
				"<leader>du",
				function() require("dapui").toggle() end,
				desc = "Toggle Debugger UI",
			},
		},
		-- automatically open/close the DAP UI when starting/stopping the debugger
		config = function()
			local listener = require("dap").listeners
			listener.after.event_initialized["dapui_config"] = function() require("dapui").open() end
			listener.before.event_terminated["dapui_config"] = function() require("dapui").close() end
			listener.before.event_exited["dapui_config"] = function() require("dapui").close() end
		end,
	},

	-- Configuration for the python debugger
	-- - configures debugpy for us
	-- - uses the debugpy installation from mason
	{
		"mfussenegger/nvim-dap-python",
		dependencies = "mfussenegger/nvim-dap",
		config = function()
			-- uses the debugypy installation by mason
			local debugpyPythonPath = require("mason-registry").get_package("debugpy"):get_install_path()
				.. "/venv/bin/python3"
			require("dap-python").setup(debugpyPythonPath, {})
		end,
	},

	-----------------------------------------------------------------------------
	-- EDITING SUPPORT PLUGINS
	-- some plugins that help with python-specific editing operations

	-- Docstring creation
	-- - quickly create docstrings via `<leader>a`
	{
		"danymat/neogen",
		opts = true,
		keys = {
			{
				"<leader>a",
				function() require("neogen").generate() end,
				desc = "Add Docstring",
			},
		},
	},

	-- f-strings
	-- - auto-convert strings to f-strings when typing `{}` in a string
	-- - also auto-converts f-strings back to regular strings when removing `{}`
	{
		"chrisgrieser/nvim-puppeteer",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},

	-- select virtual environments
	-- - makes pyright and debugpy aware of the selected virtual environment
	-- - Select a virtual environment with `:VenvSelect`
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
			"mfussenegger/nvim-dap-python",
		},
		opts = {
			dap_enabled = true, -- makes the debugger work with venv
		},
	},
}

--------------------------------------------------------------------------------

-- tell lazy.nvim to load and configure all the plugins
require("lazy").setup(plugins)
