-- Bootstrap the plugin manager `lazy.nvim`
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
-- SOME BASIC PYTHON RELATED OPTIONS

-- use pep8 standards
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- folds based on indentation https://neovim.io/doc/user/fold.html#fold-indent
-- if you are a heavy user of folds, consider the using nvim-ufo plugin
vim.opt.foldmethod = "indent"

-- make enough space for the diagnostics
vim.opt.signcolumn = "yes:1"

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
				-- define the mappings for the completion.
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
	-- SYNTAX HIGHLIGHTING

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
			ensure_installed = "python", -- auto-install the Treesitter parser for python
			highlight = { enable = true }, -- enable treesitter syntax highlighting
		},
	},

	-- COLORSCHEME
	-- In neovim, the choice of color schemes is unfortunately not purely
	-- aesthetic – treesitter highlighting or newer features like semantic
	-- highlighting are not always supported by a color scheme. It's therefore
	-- recommended to use one of the popular, and actively maintained ones to get
	-- the best syntax highlighting experience:
	-- https://dotfyle.com/neovim/colorscheme/top
	{
		"folke/tokyonight.nvim",
		-- ensure that the color scheme is loaded at once
		lazy = false,
		priority = 1000,
		-- enable the colorscheme
		config = function() vim.cmd("colorscheme tokyonight") end,
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
	-- - toggle debugger UI with `<leader>du`
	-- - the debugger UI is also automatically opened when starting/stopping the debugger
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
			listener.before.event_terminated["dapui_config"] = require("dapui").close()
			listener.before.event_exited["dapui_config"] = require("dapui").close()
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
			local debugpyPath = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python3"
			require("dap-python").setup(debugpyPath, {})
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
				desc = " Add Docstring",
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

	-- better indentation behavior
	-- by default, vim has some weird indentation behavior in some edge cases,
	-- which this plugin fixes
	{ "Vimjas/vim-python-pep8-indent" },

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
