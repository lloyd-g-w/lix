return {
	"cbochs/grapple.nvim",
	dependencies = {
		{ "nvim-tree/nvim-web-devicons", lazy = true },
	},
	config = function()
		local grapple = require("grapple")

		-- Toggle current file and tags
		vim.keymap.set("n", "<leader>m", grapple.toggle, { desc = "Grapple Toggle File" })
		vim.keymap.set("n", "<leader>M", grapple.toggle_tags, { desc = "Grapple Toggle Tags" })

		-- Select by index (1-6)
		for i = 1, 6 do
			vim.keymap.set("n", "<leader>" .. i, function()
				grapple.select({ index = i })
			end, { desc = "Grapple Select " .. i })
		end
	end,
}
