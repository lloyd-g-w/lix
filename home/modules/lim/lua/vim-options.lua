vim.cmd("set encoding=utf8")
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set nu")
vim.cmd("set termguicolors")
vim.cmd("set undodir=~/.vim/undodir")
vim.cmd("set undofile")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set cursorline")
vim.cmd("set nohlsearch")

-- Keybinds

-- Clearing annoying keybinds
vim.keymap.set("n", "<S-j>", "<Nop>")

-- Ctrl-q to exit terminal mode
vim.api.nvim_set_keymap("t", "<C-q>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "exit terminal mode" })

-- Leader cf to format with conform
-- vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format, { desc = "format" })
vim.keymap.set("n", "<leader>cf", ":Format<CR>", { silent = true, desc = "format" })

-- ERRORS
-- Leader co to open current error list and cc to close it
vim.keymap.set("n", "<leader>co", ":copen<CR>", { noremap = true, silent = true, desc = "open current error list" })
vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { noremap = true, silent = true, desc = "close current error list" })
-- Leader cn and cp to navigate through errors
vim.keymap.set("n", "<leader>cn", ":cnext<CR>", { noremap = true, silent = true, desc = "next error" })
vim.keymap.set("n", "<leader>cp", ":cprev<CR>", { noremap = true, silent = true, desc = "previous error" })

-- DIAGNOSTICS
vim.keymap.set(
	"n",
	"<leader>do",
	vim.diagnostic.open_float,
	{ noremap = true, silent = true, desc = "open hovering diagnostic" }
)
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "next error" })
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "previous error" })

-- Allows for .nvim.lua files to be loaded
vim.o.exrc = true
vim.o.secure = true
