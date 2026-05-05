vim.g.mapleader = " "

-- NeoTree
vim.keymap.set('n', '<leader>t', ':Neotree focus<CR>');      -- Open NeoTree
vim.keymap.set('n', '<leader>g', ':Neotree git_status<CR>'); -- Git stauts window
-- vim.keymap.set('n', '<leader>g', ':Neotree buffers<CR>'); -- Show a list of currently open buffers.
------------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------

local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-----------------------------------------------------------
-- Neovim shortcuts
-----------------------------------------------------------

--Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- Insert --
-- Exit insert mode
keymap("i", "<leader>k", "<ESC>", opts)

-- Visual --
-- Exit visual mode
keymap("v", "<leader>k", "<ESC>", opts)

-- Stay in indent mode
keymap("v", "<S-Tab>", "<gv", opts)
keymap("v", "<Tab>", ">gv", opts)

-- Move text up and down
-- keymap("v", "<A-j>", ":m .+1<CR>==", opts)
-- keymap("v", "<A-k>", ":m .-2<CR>==", opts)
-- keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Exit visual block mode
keymap("x", "<leader>k", "<ESC>", opts)

-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Clear search highlighting with <leader> and c
keymap('n', '<leader>c', ':nohl<CR>', opts)

-- Add surrounding characters to text
keymap("v", "<leader>(", "c()<Esc>P", opts)
keymap("v", "<leader>\"", "c\"\"<Esc>P", opts)
keymap("v", "<leader>{", "c{}<Esc>P", opts)
keymap("v", "<leader>[", "c[]<Esc>P", opts)

-- Paste and save current clipboard
keymap("v", "<leader>p", "\"_dP", opts)

-- Scroll up and down with centralized cursor position
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "<C-d>", "<C-d>zz", opts)

-- Buffer keymaps
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<S-l>", ":bnext<CR>", opts)

-- Tabs keymaps
-- keymap("n", "<leader>h", ":tabprevious<CR>", opts)
-- keymap("n", "<leader>l", ":tabnext<CR>", opts)
