return {
    'rcarriga/nvim-notify',
    config = function()
        require('notify').setup({
            stages = "fade_in_slide_out",
            timeout = 3000,
            background_colour = '#1e222a',
            text_colour = '#abb2bf',
            icons = {
                ERROR = '',
                WARN = '',
                INFO = '',
                DEBUG = '',
                TRACE = '✎',
            },
        })
    end,
}
