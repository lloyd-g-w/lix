return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"onsails/lspkind.nvim",
		"rafamadriz/friendly-snippets",
		"iurimateus/luasnip-latex-snippets.nvim",
	},
	config = function()
		build = "make install_jsregexp"
		require("luasnip.loaders.from_vscode").lazy_load()
		local cmp = require("cmp")
		cmp.setup({
			snippet = {
				-- REQUIRED - you must specify a snippet engine
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
					-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
				end,
			},
			-- window = {
			-- 	completion = cmp.config.window.bordered({
			-- 		border = "rounded",
			-- 		winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
			-- 	}),
			-- 	documentation = cmp.config.window.bordered({
			-- 		border = "rounded",
			-- 	}),
			-- },
			mapping = cmp.mapping.preset.insert({
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- For luasnip usersx.
				{ name = "buffer" },
				{ name = "path" },
			}),
		})

		require("luasnip").config.setup({ enable_autosnippets = true })

		require("luasnip-latex-snippets").setup()

		local ls = require("luasnip")
		local s = ls.snippet
		local t = ls.text_node
		local i = ls.insert_node
		local d = ls.dynamic_node
		local sn = ls.snippet_node

		-- CUSTOM SNIPPETS
		local c_type_snips = {
			s("cheadercomment", {
				t("// Lloyd Williams (z5599988) | Written on " .. os.date("%d/%m/%Y ")),
				t({ "", "// Description: " }),
			}),
			s("bigcomment", {
				t("// " .. string.rep("=", 20) .. " "),
				i(1),
				t(" " .. string.rep("=", 20) .. " //"),
			}),
		}
		ls.add_snippets("c", c_type_snips)

		ls.add_snippets("cpp", c_type_snips)

		ls.add_snippets("java", { c_type_snips[2] })

		local in_mathzone = function()
			return vim.fn["vimtex#syntax#in_mathzone"]() == 1
		end

		ls.add_snippets("tex", {
			s(
				{ trig = "bf", snippetType = "autosnippet" },
				d(1, function()
					if in_mathzone() then
						return sn(nil, {
							t("\\mathbf "),
						})
					else
						return sn(nil, {
							t("\\textbf "),
						})
					end
				end),
				{
					condition = function()
						return true
					end,
				} -- ensures it's always checked
			),
			s({ trig = "bb", snippetType = "autosnippet" }, {
				t("\\mathbb "),
			}),
		})

		ls.add_snippets("typst", {
			s({ trig = "mk", snippetType = "autosnippet" }, {
				t("$"),
				i(1),
				t(" $"),
			}),
			s({ trig = "dm", snippetType = "autosnippet" }, {
				t({ "$", "  " }),
				i(1),
				t({ "", "  .", "$" }),
			}),
		})

		require("luasnip.loaders.from_lua").load()

		-- END CUSTOM SNIPPETS

		vim.keymap.set({ "i" }, "<C-K>", function()
			ls.expand()
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-L>", function()
			ls.jump(1)
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-J>", function()
			ls.jump(-1)
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-E>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { silent = true })

		-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).

		-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).

		local lspkind = require("lspkind")
		cmp.setup({
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol_text",
					maxwidth = 35,
					menu = {
						buffer = "[Buffer]",
						nvim_lsp = "[LSP]",
						luasnip = "[LuaSnip]",
						nvim_lua = "[Lua]",
						latex_symbols = "[Latex]",
						cmdline = "[cmd]",
						path = "[Path]",
					},
				}),
			},
		})
	end,
}
