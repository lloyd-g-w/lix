return {
    "github/copilot.vim",
    config = function()
        -- change copilot keymap to ctrl f
        vim.keymap.set('i', '<C-f>', 'copilot#Accept("\\<CR>")', {
            expr = true,
            replace_keycodes = false
        })
        vim.g.copilot_no_tab_map = true
        -- disable by default
        vim.g.copilot_enabled = false
    end,
}
