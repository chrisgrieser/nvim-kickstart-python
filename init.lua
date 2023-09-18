-- Bootstrap `lazy.nvim` as the plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyIsInstalled = vim.loop.fs_stat(lazypath)
if not lazyIsInstalled then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)

--------------------------------------------------------------------------------
-- Some Python related options
-- use pep8 standards
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- folds based on indentation https://neovim.io/doc/user/fold.html#fold-indent
-- if you are a heavy user of folds, consider the using nvim-ufo plugin
vim.opt.foldmethod = "indent"

--------------------------------------------------------------------------------
-- Install & Configure Plugins
require("lazy").setup({
	--------------------------------------------------------------------------------
	-- TOOLING & LSPs

	-- manager for external tools (LSPs, linters, debuggers, formatters)
	-- auto-install of those external tools
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = "williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"pyright", -- LSP for python
				"ruff-lsp", -- linter for python (includes flake8, pep8, etc.)
				"debugpy", -- debugger
				"black", -- formatter
				"taplo", -- LSP for toml (for pyproject.toml files)
			},
		},
	},

	-- Setup the LSPs
	{
		"neovim/nvim-lspconfig",
		-- `gd` and `gr` for goto definition and references
		-- `<leader>c` for code actions (organize imports, etc.)
		keys = {
			{ "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
			{ "gr", vim.lsp.buf.references, desc = "Goto References" },
			{ "<leader>c", vim.lsp.buf.code_action, desc = "Code Action" },
		},
		init = function()
			-- enable auto-completion for nvim-cmp
			local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
			lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

			require("lspconfig").pyright.setup({
				capabilities = lspCapabilities,
				-- pyright configuration options are entered here
				-- https://github.com/microsoft/pyright/blob/main/docs/settings.md
				settings = {
					pyright = {},
				},
			})

			-- ruff uses an LSP proxy, therefore it needs to be enabled as if it
			-- were a LSP. In practice, ruff only provides linter-like diagnostics
			-- and some code actions, and is not a full LSP (yet).
			require("lspconfig").ruff_lsp.setup({
				-- organize imports & auto-fixing as code actions
				settings = {
					organizeImports = true,
					fixall = true,
				},
				-- disable ruff as hover provider, since we are using pyright for that
				on_attach = function(client) client.server_capabilities.hoverProvider = false end,
			})

			require("lspconfig").taplo.setup({
				capabilities = lspCapabilities,
			})
		end,
	},

	-----------------------------------------------------------------------------
	-- SYNTAX HIGHLIGHTING

	-- use treesitter for syntax highlighting and auto-install the parser for python
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = "python",
			highlight = { enable = true },
		},
	},

	-- better indentation behavior
	{
		"Vimjas/vim-python-pep8-indent",
		ft = "python",
	},

	-----------------------------------------------------------------------------
	-- DEBUGGING

	-- DAP Client for nvim
	{
		"mfussenegger/nvim-dap",
		-- start the debugger with `<leader>dc`
		-- add breakpoints with `<leader>db`
		-- terminate the debugger `<leader>dt`
		keys = {
			{
				"<leader>dc",
				function() require("dap").continue() end,
				desc = "Start/Continue Debugger",
			},
			{
				"<leader>db",
				function() require("dap").toggle_breakpoint() end,
				desc = "B Add Breakpoint",
			},
			{
				"<leader>dt",
				function() require("dap").terminate() end,
				desc = " Terminate Debugger",
			},
		},
	},

	-- UI for the debugger
	{
		"rcarriga/nvim-dap-ui",
		dependencies = "mfussenegger/nvim-dap",
		-- automatically open/close the DAP UI when starting/stopping the debugger
		config = function()
			local listener = require("dap").listeners
			listener.after.event_initialized["dapui_config"] = function() require("dapui").open() end
			listener.before.event_terminated["dapui_config"] = require("dapui").close()
			listener.before.event_exited["dapui_config"] = require("dapui").close()
		end,
	},

	-----------------------------------------------------------------------------
	-- EDITING SUPPORT PLUGINS

	-- quickly create docstrings via `<leader>d`
	{
		"danymat/neogen",
		opts = true,
		keys = {
			{
				"<leader>a",
				function() require("neogen").generate() end,
				desc = " Add Docstring",
			},
		},
	},
	-- auto-convert strings to f-strings and back
	{
		"chrisgrieser/nvim-puppeteer",
		ft = "python",
	},
	-- support: conveniently select virtual environments
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
			"mfussenegger/nvim-dap-python",
		},
		cmd = { "VenvSelect", "VenvSelectCached" },
		opts = {
			dap_enabled = true, -- makes the debugger work with venv
		},
		init = function()
			-- auto-select venv when entering a python buffer
			-- https://github.com/linux-cultist/venv-selector.nvim#-automate
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				callback = function()
					local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
					if venv ~= "" then require("venv-selector").retrieve_from_cache() end
				end,
			})
		end,
	},
})
