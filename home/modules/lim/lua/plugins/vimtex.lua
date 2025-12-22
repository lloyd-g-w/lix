return {
    "lervag/vimtex",
    lazy = false,
    init = function()
        -- vim.cmd("set conceallevel=2")
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_compiler_method = "latexmk"
        vim.g.vimtex_compiler_latexmk = {
            aux_dir = ".build",
        }

        -- Use init for configuration, don't use the more common "config".
    end
}
