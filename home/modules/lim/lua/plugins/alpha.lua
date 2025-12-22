return {
	"goolord/alpha-nvim",
	dependencies = { "catppuccin/nvim" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Catppuccin palette
		-- local cp = require("catppuccin.palettes").get_palette("macchiato")
		-- Define a highlight group for our header
		-- vim.api.nvim_set_hl(0, "AlphaHeader", { fg = cp.peach, bg = cp.base })
		-- vim.api.nvim_set_hl(0, "AlphaHeader", { link = "Title" })
		-- local accent = vim.api.nvim_get_hl(0, { name = "String" }).fg
		-- vim.api.nvim_set_hl(0, "AlphaHeader", { fg = accent })
		vim.api.nvim_set_hl(0, "AlphaHeader", { link = "Keyword" })

		-- Cool Catppuccin-style ASCII art
		dashboard.section.header.val = {
			[[ ██╗     ██╗███╗   ███╗ ]],
			[[ ██║     ██║████╗ ████║ ]],
			[[ ██║     ██║██╔████╔██║ ]],
			[[ ██║     ██║██║╚██╔╝██║ ]],
			[[ ███████╗██║██║ ╚═╝ ██║ ]],
			[[ ╚══════╝╚═╝╚═╝     ╚═╝ ]],
		}
		dashboard.section.header.opts.hl = "AlphaHeader"

		-- Buttons
		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
			dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
			dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
			dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
		}

		alpha.setup(dashboard.opts)
	end,
}
