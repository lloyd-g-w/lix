vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.ts" },
    callback = function()
        vim.cmd("setlocal shiftwidth=2 tabstop=2 expandtab")
    end
})
