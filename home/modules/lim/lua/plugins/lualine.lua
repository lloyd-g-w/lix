return {
	"nvim-lualine/lualine.nvim",

	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			priority = 500,
			options = {
				-- theme = "gruvbox-material",
				theme = "onedark",
				section_separators = { "" },
				component_separators = { "" },
			},
		})
	end,
}
