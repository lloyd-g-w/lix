return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts =
    {
        indent = {
            char = "│",
            -- char = "▏",
        },
        scope = {
            show_start = false,
            show_end = false,
            enabled = true,
        },
    }

}

-- return {
--     "shellRaining/hlchunk.nvim",
--     event = { "UIEnter" },
--     config = function()
--         require("hlchunk").setup({
--             chunk = { enable = true },
--             blank = { enable = false },
--             line_num = { enable = false },
--             indent = {
--                 enable = true,
--                 use_treesitter = true,
--                 chars = {
--                     "│",
--                 },
--                 style = {
--                     { fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") }
--                 },
--             },
--
--         })
--     end
-- }
