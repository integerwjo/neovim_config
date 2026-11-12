-- ~/.config/nvim/init.lua
-- Neovim configuration.

vim.o.guifont = "JetBrainsMono Nerd Font Mono:h10"

if vim.fn.has("nvim-0.11") == 0 then
	vim.api.nvim_echo(
		{ { "This config needs Neovim >= 0.11 (you have " .. tostring(vim.version()) .. ").\n", "ErrorMsg" } },
		true,
		{}
	)
	return
end

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Add user-local tools to PATH.
do
	local dirs = vim.split(vim.env.PATH or "", ":", { plain = true })
	for _, dir in ipairs({ "~/.cargo/bin", "~/.local/bin" }) do
		local bin = vim.fn.expand(dir)
		if not vim.tbl_contains(dirs, bin) then
			table.insert(dirs, 1, bin)
		end
	end
	vim.env.PATH = table.concat(dirs, ":")
end

-- Options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.mouse = "a"
o.showmode = false -- statusline shows it
o.clipboard = "unnamedplus"

-- Use xsel to avoid wl-copy flicker; fall back if missing.
if vim.fn.executable("xsel") == 1 then
	vim.g.clipboard = {
		name = "xsel",
		copy = {
			["+"] = { "xsel", "--input", "--clipboard" },
			["*"] = { "xsel", "--input", "--primary" },
		},
		paste = {
			["+"] = { "xsel", "--output", "--clipboard" },
			["*"] = { "xsel", "--output", "--primary" },
		},
		cache_enabled = 0,
	}
end
o.breakindent = true
o.undofile = true
o.swapfile = false
o.ignorecase = true
o.smartcase = true
o.signcolumn = "yes"
o.updatetime = 250
o.timeoutlen = 400
o.splitright = true
o.splitbelow = true
o.cursorline = true
o.scrolloff = 8
o.termguicolors = true
o.confirm = true
o.wrap = false
o.inccommand = "split"
o.winborder = "rounded"

-- Show tabs and trailing whitespace.
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Default indentation.
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.smartindent = true

-- Treesitter folding.
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevelstart = 99

-- Netrw: quiet listing.
vim.g.netrw_banner = 0 -- drop the header comment lines
vim.g.netrw_list_hide = [[^\./$]] -- drop the ./ entry

-- Keymaps
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })

-- File navigation.
map("n", "-", "<cmd>Explore %:h<cr>", { desc = "Open netrw file browser" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Move selected lines, keep selection when indenting
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Terminal navigation.
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>")
map("t", "<C-j>", "<cmd>wincmd j<cr>")
map("t", "<C-k>", "<cmd>wincmd k<cr>")
map("t", "<C-l>", "<cmd>wincmd l<cr>")

-- Build and show errors in quickfix.
map("n", "<leader>mm", function()
	vim.cmd("silent make")
	local has_valid = false
	for _, item in ipairs(vim.fn.getqflist()) do
		if item.valid == 1 then
			has_valid = true
			break
		end
	end
	if has_valid then
		vim.cmd("copen")
	elseif vim.v.shell_error ~= 0 then
		vim.notify("Build failed (see :messages)", vim.log.levels.ERROR)
	else
		vim.notify("Build succeeded", vim.log.levels.INFO)
	end
end, { desc = "Make / build (errors to quickfix)" })

-- Diagnostics
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Line diagnostics (float)" })

-- Hex view; read-only while active.
local function toggle_hex()
	if vim.fn.executable("xxd") == 0 then
		vim.notify("xxd is not installed", vim.log.levels.ERROR)
		return
	end
	if vim.b.hex_mode then
		vim.cmd("%!xxd -r")
		vim.bo.binary = vim.b.hex_orig_binary or false
		vim.bo.readonly = vim.b.hex_orig_readonly or false
		vim.b.hex_mode = false
		vim.b.hex_orig_binary = nil
		vim.b.hex_orig_readonly = nil
	else
		vim.b.hex_orig_binary = vim.bo.binary
		vim.b.hex_orig_readonly = vim.bo.readonly
		vim.bo.binary = true
		vim.cmd("%!xxd")
		vim.bo.readonly = true
		vim.b.hex_mode = true
	end
end
map("n", "<leader>uh", toggle_hex, { desc = "Toggle hex view (xxd)" })

map("n", "<leader>ui", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- Optional column ruler.
map("n", "<leader>ur", function()
	vim.wo.colorcolumn = vim.wo.colorcolumn == "" and "80" or ""
end, { desc = "Toggle ruler (colorcolumn)" })

-- Autocmds and language settings
local function augroup(name)
	return vim.api.nvim_create_augroup("user-" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
	group = augroup("yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

-- Restore last cursor position
autocmd("BufReadPost", {
	group = augroup("restore-cursor"),
	callback = function(ev)
		if vim.bo[ev.buf].buftype ~= "" then
			return
		end
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Terminal buffers: no line numbers
autocmd("TermOpen", {
	group = augroup("term-open"),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

local function ft_opts(pattern, opts)
	autocmd("FileType", {
		group = augroup("ft-" .. (type(pattern) == "table" and pattern[1] or pattern)),
		pattern = pattern,
		callback = function()
			for k, v in pairs(opts) do
				vim.opt_local[k] = v
			end
		end,
	})
end

ft_opts("go", { expandtab = false, tabstop = 4, shiftwidth = 4 })
ft_opts({ "asm", "nasm" }, { expandtab = false, tabstop = 8, shiftwidth = 8, softtabstop = 0 })
ft_opts("make", { expandtab = false })
ft_opts({ "c", "cpp" }, { tabstop = 4, shiftwidth = 4 })

autocmd("FileType", { group = augroup("compiler-rust"), pattern = "rust", command = "compiler cargo" })
autocmd("FileType", { group = augroup("compiler-go"), pattern = "go", command = "compiler go" })

-- GAS uses '#', NASM-family uses ';'.
autocmd("FileType", {
	group = augroup("asm-comment"),
	pattern = { "asm", "nasm", "masm", "tasm", "fasm" },
	callback = function()
		local syn = vim.b.asmsyntax
		if syn == nil or syn == "" then
			syn = vim.g.asmsyntax
		end
		if syn == nil or syn == "" then
			syn = vim.bo.filetype
		end
		local semicolon = { nasm = true, masm = true, tasm = true, fasm = true }
		vim.bo.commentstring = semicolon[syn] and "; %s" or "# %s" -- '// %s' for ARM GAS
	end,
})

-- Extra tree-sitter filetypes.
vim.treesitter.language.register("linkerscript", "ld")
vim.treesitter.language.register("devicetree", "dts")

-- Diagnostics and inlay hints
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	underline = true,
	virtual_text = { spacing = 2, prefix = "●" },
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚",
			[vim.diagnostic.severity.WARN] = "󰀪",
			[vim.diagnostic.severity.INFO] = "󰋽",
			[vim.diagnostic.severity.HINT] = "󰌶",
		},
	},
})

vim.lsp.inlay_hint.enable(true)

-- LSP keymaps (native gr*/K/[d/]d still work).
autocmd("LspAttach", {
	group = augroup("lsp-attach"),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local function lmap(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
		end

		lmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
		lmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		lmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
		if vim.bo[ev.buf].filetype ~= "rust" then
			lmap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
		end
		if client and client.name == "clangd" then
			lmap("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch source/header")
		end
	end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Failed to clone lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
-- Cycle colorschemes.
local _theme_i = 0
map("n", "<leader>uc", function()
	local schemes = vim.fn.getcompletion("", "color")
	table.sort(schemes)
	_theme_i = _theme_i % #schemes + 1
	vim.cmd.colorscheme(schemes[_theme_i])
	vim.notify("Colorscheme: " .. schemes[_theme_i])
end, { desc = "Cycle colorschemes" })

local plugins = {

	-- Colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha",
			auto_integrations = false,
			integrations = {
				blink_cmp = true,
				gitsigns = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
				fzf = true,
				mason = true,
				dap = true,
				dap_ui = true,
				lsp_trouble = true,
				native_lsp = { enabled = true },
				indent_blankline = { enabled = true },
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},

	-- Extra colorschemes (<leader>uc to cycle).
	{ "folke/tokyonight.nvim", priority = 1000 }, -- :colorscheme tokyonight-moon
	{ "rose-pine/neovim", name = "rose-pine", priority = 1000 }, -- :colorscheme rose-pine-moon
	{ "rebelot/kanagawa.nvim", priority = 1000 }, -- :colorscheme kanagawa
	{ "sainnhe/everforest", priority = 1000 }, -- :colorscheme everforest
	{ "EdenEast/nightfox.nvim", priority = 1000 }, -- :colorscheme nightfox
	{ "Mofiqul/dracula.nvim", priority = 1000 }, -- :colorscheme dracula
	{ "nyoom-engineering/oxocarbon.nvim", priority = 1000 }, -- :colorscheme oxocarbon

	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		config = function()
			local function lsp_names()
				local names = {}
				for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
					names[#names + 1] = c.name
				end
				return table.concat(names, ",")
			end
			require("lualine").setup({
				options = { theme = "auto", globalstatus = true },
				sections = {
					lualine_x = { lsp_names, "encoding", "filetype" },
				},
			})
		end,
	},

	-- Keymap hints
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			spec = {
				{ "<leader>f", group = "find" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "debug" },
				{ "<leader>h", group = "git hunks" },
				{ "<leader>m", group = "make" },
				{ "<leader>r", group = "rust / rename" },
				{ "<leader>t", group = "terminal" },
				{ "<leader>u", group = "ui toggles" },
				{ "<leader>x", group = "diagnostics / lists" },
			},
		},
	},

	-- Fuzzy finder
	{
		"ibhagwan/fzf-lua",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>ff",
				function()
					require("fzf-lua").files()
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>fw",
				function()
					require("fzf-lua").grep_cword()
				end,
				desc = "Grep word under cursor",
			},
			{
				"<leader>fb",
				function()
					require("fzf-lua").buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fo",
				function()
					require("fzf-lua").oldfiles()
				end,
				desc = "Recent files",
			},
			{
				"<leader>fh",
				function()
					require("fzf-lua").helptags()
				end,
				desc = "Help tags",
			},
			{
				"<leader>fk",
				function()
					require("fzf-lua").keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>fs",
				function()
					require("fzf-lua").lsp_document_symbols()
				end,
				desc = "Document symbols",
			},
			{
				"<leader>fS",
				function()
					require("fzf-lua").lsp_live_workspace_symbols()
				end,
				desc = "Workspace symbols",
			},
			{
				"<leader>fd",
				function()
					require("fzf-lua").diagnostics_document()
				end,
				desc = "Document diagnostics",
			},
			{
				"<leader>fD",
				function()
					require("fzf-lua").diagnostics_workspace()
				end,
				desc = "Workspace diagnostics",
			},
			{
				"<leader>fr",
				function()
					require("fzf-lua").resume()
				end,
				desc = "Resume last search",
			},
			{
				"<leader>/",
				function()
					require("fzf-lua").blines()
				end,
				desc = "Search in buffer",
			},
			{ "<leader>fT", "<cmd>TodoFzfLua<cr>", desc = "TODO/FIXME comments" },
		},
		config = function()
			local fzf = require("fzf-lua")
			fzf.setup({ winopts = { border = "rounded" } })
			fzf.register_ui_select() -- code actions etc. use fzf too
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local parsers = {
				"c",
				"cpp",
				"rust",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"asm",
				"nasm",
				"linkerscript",
				"devicetree",
				"proto",
				"make",
				"cmake",
				"bash",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
				"toml",
				"yaml",
				"json",
				"diff",
				"gitcommit",
				"git_config",
				"gitignore",
				"regex",
			}
			if vim.fn.executable("tree-sitter") == 1 then
				require("nvim-treesitter").install(parsers) -- async, no-op once installed
			else
				vim.notify(
					"tree-sitter CLI not found: install it (see setup notes) to get parsers",
					vim.log.levels.WARN
				)
			end

			-- Start highlighting when a parser exists.
			autocmd("FileType", {
				group = augroup("treesitter-start"),
				callback = function(ev)
					pcall(vim.treesitter.start, ev.buf)
				end,
			})
		end,
	},

	-- Sticky context header
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		opts = { max_lines = 3 },
		keys = {
			{
				"[x",
				function()
					require("treesitter-context").go_to_context(vim.v.count1)
				end,
				desc = "Jump to context",
			},
		},
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			require("mason").setup({ ui = { border = "rounded" } })

			vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

			-- C / C++
			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
				},
			})

			-- Go
			vim.lsp.config("gopls", {
				settings = {
					gopls = {
						gofumpt = true,
						staticcheck = true,
						usePlaceholders = true,
						completeUnimported = true,
						analyses = { unusedparams = true, shadow = true, unusedwrite = true },
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			})

			-- Lua
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = { checkThirdParty = false },
						completion = { callSnippet = "Replace" },
						telemetry = { enable = false },
					},
				},
			})

			-- asm-lsp is installed outside Mason.
			vim.lsp.config("asm_lsp", { filetypes = { "asm", "vmasm", "nasm" } })

			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "gopls", "lua_ls", "bashls" },
				automatic_enable = { exclude = { "rust_analyzer", "asm_lsp" } },
			})

			if vim.fn.executable("asm-lsp") == 1 then
				vim.lsp.enable("asm_lsp")
			end

			-- Formatters and debug adapters.
			require("mason-tool-installer").setup({
				ensure_installed = { "stylua", "clang-format", "goimports", "gofumpt", "delve", "codelldb" },
			})
		end,
	},

	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
	},

	-- Rust
	{
		"mrcjkb/rustaceanvim",
		version = "^6",
		lazy = false, -- lazy-loads itself on rust filetypes
		init = function()
			vim.g.rustaceanvim = function()
				return {
					server = {
						capabilities = require("blink.cmp").get_lsp_capabilities(),
						on_attach = function(_, bufnr)
							local function rmap(lhs, rhs, desc)
								vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = "Rust: " .. desc })
							end
							rmap("<leader>ca", function()
								vim.cmd.RustLsp("codeAction")
							end, "Code action")
							rmap("K", function()
								vim.cmd.RustLsp({ "hover", "actions" })
							end, "Hover actions")
							rmap("<leader>rr", function()
								vim.cmd.RustLsp("runnables")
							end, "Runnables")
							rmap("<leader>rt", function()
								vim.cmd.RustLsp("testables")
							end, "Testables")
							rmap("<leader>rd", function()
								vim.cmd.RustLsp("debuggables")
							end, "Debuggables")
							rmap("<leader>re", function()
								vim.cmd.RustLsp("expandMacro")
							end, "Expand macro")
							rmap("<leader>rc", function()
								vim.cmd.RustLsp("openCargo")
							end, "Open Cargo.toml")
							rmap("<leader>rp", function()
								vim.cmd.RustLsp("parentModule")
							end, "Parent module")
							rmap("<leader>rx", function()
								vim.cmd.RustLsp("explainError")
							end, "Explain error")
						end,
						default_settings = {
							["rust-analyzer"] = {
								cargo = { allFeatures = true },
								check = { command = "clippy" },
								procMacro = { enable = true },
							},
						},
					},
				}
			end
		end,
	},

	-- Completion
	{
		"saghen/blink.cmp",
		version = "1.*", -- prebuilt fuzzy-matching binaries
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "none",
				["<CR>"] = { "accept", "snippet_forward", "fallback" },
				["<C-y>"] = { "accept", "fallback" },
				["<Tab>"] = { "accept", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
				kind_icons = {
					Text = "T",
					Method = "M",
					Function = "F",
					Constructor = "C",
					Field = "F",
					Variable = "V",
					Class = "C",
					Interface = "I",
					Module = "M",
					Property = "P",
					Unit = "U",
					Value = "V",
					Enum = "E",
					Keyword = "K",
					Snippet = "S",
					Color = "C",
					File = "F",
					Reference = "R",
					Folder = "D",
					EnumMember = "E",
					Constant = "C",
					Struct = "S",
					Event = "E",
					Operator = "O",
					TypeParameter = "T",
				},
			},
			completion = {
				list = { selection = { preselect = true, auto_insert = false } },
				documentation = { auto_show = true, auto_show_delay_ms = 300 },
			},
			signature = { enabled = true },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
		},
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true })
				end,
				desc = "Format buffer",
			},
		},
		init = function()
			vim.g.autoformat = true
			vim.api.nvim_create_user_command("FormatToggle", function()
				vim.g.autoformat = not vim.g.autoformat
				vim.notify("Format on save: " .. (vim.g.autoformat and "ON" or "OFF"))
			end, { desc = "Toggle format on save" })
		end,
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				go = { "goimports", "gofumpt" },
				asm = { "trim_whitespace" },
				-- Rust: rustfmt via rust-analyzer.
			},
			formatters = {
				-- Respect project .clang-format when present.
				["clang-format"] = { prepend_args = { "--fallback-style=none" } },
			},
			default_format_opts = { lsp_format = "fallback" },
			format_on_save = function(bufnr)
				if not vim.g.autoformat then
					return nil
				end
				-- Skip buffers larger than 1 MiB.
				local size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
				if size > 1024 * 1024 then
					return nil
				end
				return { timeout_ms = 1000, lsp_format = "fallback" }
			end,
		},
	},

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"leoluz/nvim-dap-go",
		},
		keys = {
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "Debug: start/continue",
			},
			{
				"<F10>",
				function()
					require("dap").step_over()
				end,
				desc = "Debug: step over",
			},
			{
				"<F11>",
				function()
					require("dap").step_into()
				end,
				desc = "Debug: step into",
			},
			{
				"<F12>",
				function()
					require("dap").step_out()
				end,
				desc = "Debug: step out",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Condition: "))
				end,
				desc = "Conditional breakpoint",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run last",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Open REPL",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle debug UI",
			},
			{
				"<leader>dx",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<leader>dt",
				function()
					require("dap-go").debug_test()
				end,
				desc = "Debug Go test",
				ft = "go",
			},
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()
			require("nvim-dap-virtual-text").setup()
			require("dap-go").setup()

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = { command = "codelldb", args = { "--port", "${port}" } },
			}

			local function ask_exe()
				local default = vim.fn.expand("%:p:r")
				if default == "" then
					default = vim.fn.getcwd() .. "/"
				end
				local input = vim.fn.input("Executable: ", default, "file")
				return input ~= "" and input or default
			end

			dap.configurations.c = {
				{
					name = "Launch executable",
					type = "codelldb",
					request = "launch",
					program = ask_exe,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
				{
					name = "Attach to process",
					type = "codelldb",
					request = "attach",
					pid = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
			}
			dap.configurations.cpp = dap.configurations.c
			-- Assembly: stop at entry.
			dap.configurations.asm = {
				{
					name = "Launch (stop at entry)",
					type = "codelldb",
					request = "launch",
					program = ask_exe,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
				},
			}
			dap.configurations.nasm = dap.configurations.asm
			dap.configurations.vmasm = dap.configurations.asm
		end,
	},

	-- Terminal
	-- Floats by default; <Esc><Esc> closes.
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			direction = "float",
			close_on_exit = true,
			float_opts = { border = "rounded", width = 120, height = 30 },
			open_mapping = nil,
		},
		keys = {
			{
				"<C-\\>",
				function()
					require("toggleterm").toggle(vim.v.count1)
				end,
				desc = "Terminal (float)",
			},
			{
				"<Esc><Esc>",
				"<C-\\><C-n>:q<cr>",
				mode = "t",
				desc = "Close terminal",
			},
			{
				"<leader>tt",
				function()
					require("toggleterm").toggle(vim.v.count1)
				end,
				desc = "Terminal (float)",
			},
			{
				"<leader>tf",
				function()
					require("toggleterm").toggle(vim.v.count1, nil, "float")
				end,
				desc = "Terminal (force float)",
			},
			{
				"<leader>tv",
				function()
					require("toggleterm").toggle(vim.v.count1, nil, "vertical")
				end,
				desc = "Terminal (vertical)",
			},
			{
				"<leader>tb",
				function()
					require("toggleterm").toggle(vim.v.count1, nil, "horizontal")
				end,
				desc = "Terminal (bottom)",
			},
		},
	},

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local function gmap(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = "Git: " .. desc })
				end
				gmap("]h", function()
					gs.nav_hunk("next")
				end, "Next hunk")
				gmap("[h", function()
					gs.nav_hunk("prev")
				end, "Previous hunk")
				gmap("<leader>hs", gs.stage_hunk, "Stage hunk")
				gmap("<leader>hr", gs.reset_hunk, "Reset hunk")
				gmap("<leader>hp", gs.preview_hunk, "Preview hunk")
				gmap("<leader>hb", function()
					gs.blame_line({ full = true })
				end, "Blame line")
				gmap("<leader>hd", gs.diffthis, "Diff this")
			end,
		},
	},

	-- Diagnostics and quickfix
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols outline" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list (:make output)" },
		},
	},

	-- TODO comments
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},

	-- Mini.nvim
	{
		"echasnovski/mini.nvim",
		version = false,
		event = "VeryLazy",
		config = function()
			require("mini.pairs").setup()
			require("mini.surround").setup()
			require("mini.ai").setup({ n_lines = 500 })
		end,
	},

	-- Indent guides.
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = { enabled = true, scope = { enabled = false } },
	},
}

require("lazy").setup(plugins, {
	ui = { border = "rounded" },
	checker = { enabled = false },
	change_detection = { notify = false },
	rocks = { enabled = false },
})
