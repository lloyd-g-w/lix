return {
	"folke/which-key.nvim",
	dependencies = {
		{ "echasnovski/mini.icons", version = "*" },
	},
	opts = {
		defaults = {},
		spec = {
			{
				mode = { "n", "v" },
				{ "<leader>f", group = "file" },
				{ "<leader>c", group = "code" },
			},
		},
	},
	event = "VeryLazy",
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = true })
			end,
			desc = "buffer Keymaps (which-key)",
		},
		{
			"<leader>f",
			group = "file",
		},
		{
			"<leader>fe",
			function()
				vim.cmd("Oil")
			end,
			desc = "file explorer",
		},
	},
}
