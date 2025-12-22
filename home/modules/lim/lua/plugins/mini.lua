return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function()
		require("mini.ai").setup()
		-- require("mini.files").setup({
		-- 	options = { permanent_delete = false },
		-- })
		require("mini.extra").setup({})
		require("mini.hipatterns").setup({})
		require("mini.cursorword").setup({})
		require("mini.move").setup({})
	end,
}
