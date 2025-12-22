return {
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")
		local util = require("lspconfig.util")
		local make_caps = vim.lsp.protocol.make_client_capabilities

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "lsp go to definition" })
		vim.keymap.set("n", "K", function()
			-- vim.lsp.buf.hover({ border = "rounded" })
			vim.lsp.buf.hover()
		end, { desc = "LSP hover" })
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, { desc = "lsp code actions" })

		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		local caps = make_caps()
		caps.offsetEncoding = { "utf-16" }

		lspconfig.hls.setup({})
		-- lspconfig.ccls.setup({})
		lspconfig.clangd.setup({
			cmd = {
				"clangd",
				"--background-index",
			},
		})
		lspconfig.nixd.setup({})
		lspconfig.rust_analyzer.setup({})

		lspconfig.ocamllsp.setup({
			settings = {
				merlinDiagnostics = { enable = true },
				extendedHover = { enable = true },
				codelens = { enable = true },
				inlayHints = { enable = true },
				syntaxDocumentation = { enable = true },
				merlinJumpCodeActions = { enable = true },
				-- duneDiagnostics = { enable = true },
				-- merlinDiagnostics is for the Jane Street fork of ocamllsp
			},
		})

		lspconfig.svelte.setup({
			on_attach = function(client, bufnr) end,
		})
		lspconfig.tinymist.setup({
			settings = {
				formatterMode = "typstyle", -- use typstyle inside Tinymist
				formatterPrintWidth = 80, -- line width
				formatterIndentSize = 2, -- indent
				formatterProseWrap = true, -- wrap prose at print width
			},
		}) -- Typst
		lspconfig.csharp_ls.setup({})
		lspconfig.ts_ls.setup({})
		lspconfig.basedpyright.setup({})
		lspconfig.vimls.setup({})
		lspconfig.lua_ls.setup({})
		lspconfig.cmake.setup({})
		lspconfig.zls.setup({})
		lspconfig.texlab.setup({})
		lspconfig.qmlls.setup({})
	end,
}
