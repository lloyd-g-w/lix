return {
	{
		"dracula/vim",
		name = "dracula",
		priority = 1000,
		config = function()
			-- vim.o.background = "dark" -- or "light" for light mode
			-- vim.g.gruvbox_material_background = "soft"
			-- vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
			-- vim.cmd([[colorscheme gruvbox-material]])
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		-- config = function()
		--     -- Default options:
		--     require("gruvbox").setup({
		--         terminal_colors = true, -- add neovim terminal colors
		--         undercurl = true,
		--         underline = true,
		--         bold = true,
		--         italic = {
		--             strings = true,
		--             emphasis = true,
		--             comments = true,
		--             operators = false,
		--             folds = true,
		--         },
		--         strikethrough = true,
		--         invert_selection = false,
		--         invert_signs = false,
		--         invert_tabline = false,
		--         invert_intend_guides = false,
		--         inverse = true, -- invert background for search, diffs, statuslines and errors
		--         contrast = "soft", -- can be "hard", "soft" or empty string
		--         palette_overrides = {},
		--         overrides = {},
		--         dim_inactive = false,
		--         transparent_mode = false,
		--     })
		-- vim.cmd("colorscheme gruvbox")
		-- end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1500,
		-- config = function()
		-- 	require("catppuccin").setup({
		-- 		auto_integrations = true,
		-- 		flavour = "macchiato", -- latte, frappe, macchiato, mocha
		-- 	})
		-- 	vim.cmd.colorscheme("catppuccin")
		-- end,
	},
	{
		"navarasu/onedark.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("onedark").setup({
				style = "warm",
			})
			require("onedark").load()
		end,
	},
	{ "projekt0n/github-nvim-theme", name = "github-theme" },
	{ "rebelot/kanagawa.nvim" },
	{ "sainnhe/edge" },
	{ "shaunsingh/nord.nvim" },
	{ "Mofiqul/dracula.nvim" },
}
