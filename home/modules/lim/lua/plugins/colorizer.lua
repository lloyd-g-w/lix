return {
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	config = function()
		require("colorizer").setup({
			filetypes = {
				"*", -- Highlight all files, but customize some others.
				css = { rgb_fn = true, oklch_fn = true }, -- Enable parsing rgb(...) and oklch(...) functions in css.
			},
		})
	end,
}
