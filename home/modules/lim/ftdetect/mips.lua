vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.s" },
    callback = function()
        vim.cmd("setlocal shiftwidth=8 tabstop=8 noexpandtab")
    end
})
