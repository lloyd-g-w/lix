return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "black" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettier" },
				typescript = { "prettier" },
				yaml = { "yq" },
				json = { "jq" },
				jsonc = { "prettier" },
				nix = { "alejandra" },
				tex = { "tex-fmt" },
				css = { "prettier" },
				markdown = { "markdownlint" },
				cpp = { "clang-format" },
				c = { "clang-format",  "astyle" },
				ocaml = { "ocamlformat" },
				-- typst = { "typstyle" },
			},
		})

		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			require("conform").format({ async = true, lsp_format = "fallback", range = range })
		end, { range = true })
	end,
}
