-----------------------------------------------------------
-- General Neovim settings and configuration
-----------------------------------------------------------

-- Default options are not included
-- See: https://neovim.io/doc/user/vim_diff.html
-- [2] Defaults - *nvim-defaults*

local g = vim.g -- Global variables

-----------------------------------------------------------
-- General
-----------------------------------------------------------
vim.opt.mouse = 'a'                               -- Enable mouse support
vim.opt.clipboard = "unnamedplus"                 -- Copy/paste to system clipboard
vim.opt.swapfile = false                          -- Don't use swapfile
vim.opt.completeopt = 'menuone,noinsert,noselect' -- Autocomplete options
vim.opt.fileencoding = "utf-8"                    -- The encoding written to a file
vim.lsp.log.set_level(vim.lsp.log.levels.OFF)     -- Disable LSP client log
-- vim.highlight.priorities.semantic_tokens = 99       -- Lower semantic tokens priority


-----------------------------------------------------------
-- No end of file when saving
-----------------------------------------------------------
vim.opt.binary = true
vim.opt.endofline = false
vim.g.noeol = true

-----------------------------------------------------------
-- Neovim UI
-----------------------------------------------------------
vim.opt.number = false                     -- Set numbered lines
vim.opt.showmatch = true                   -- Highlight matching parenthesis
vim.opt.foldmethod = 'marker'              -- Enable folding (default 'foldmarker')
vim.opt.splitright = true                  -- Vertical split to the right
vim.opt.splitbelow = true                  -- Horizontal split to the bottom
vim.opt.ignorecase = true                  -- Ignore case letters when search
vim.opt.smartcase = true                   -- Ignore lowercase for the whole pattern
vim.opt.linebreak = true                   -- Wrap on word boundary
vim.opt.termguicolors = true               -- Enable 24-bit RGB colors
vim.opt.laststatus = 3                     -- Set global statusline
vim.opt.undofile = true                    -- Enable persistent undo
vim.opt.wrap = true                        -- Display lines as one long line
vim.opt.linebreak = true                   -- Companion to wrap, don't split words
vim.opt.cursorline = true                  -- Highlight cursor line
vim.opt.colorcolumn = '101'                -- Line lenght marker at 101 columns
vim.wo.number = true                       -- Hybrid number lines
vim.wo.relativenumber = true               -- Hybrid number lines
vim.opt.guicursor = "n-v-i-c:block-Cursor" -- Block cursorim.wo.relativenumber = true

-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
vim.opt.expandtab = true    -- Use spaces instead of tabs
vim.opt.shiftwidth = 4      -- Shift 4 spaces when tab
vim.opt.tabstop = 4         -- 1 tab == 4 spaces
vim.opt.smartindent = false -- Autoindent new lines
vim.opt.signcolumn = "yes"  -- Always show the sign column, otherwise it would shift the text each time
vim.opt.scrolloff = 8       -- Minimal number of screen lines to keep above and below the cursor
vim.opt.sidescrolloff = 8   -- Minimal number of screen columns either side of cursor if wrap is `false`

-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
vim.opt.hidden = true    -- Enable background buffers
vim.opt.history = 100    -- Remember N lines in history
vim.opt.synmaxcol = 240  -- Max column for syntax highlight
vim.opt.updatetime = 250 -- Ms to wait for trigger an event

-----------------------------------------------------------
-- Font
-----------------------------------------------------------
vim.opt.guifont = "monospace:h17" -- The font used in graphical neovim applications

-----------------------------------------------------------
-- Wrap
-----------------------------------------------------------
vim.opt.whichwrap = "bs<>[]hl" -- Which "horizontal" keys are allowed to travel to prev/next line

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
vim.opt.shortmess:append "c" -- Don't give |ins-completion-menu| messages
vim.opt.iskeyword:append "-" -- Hyphenated words recognized by searches

-----------------------------------------------------------
-- Highlight text on yank
-----------------------------------------------------------
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_yank', {}),
    desc = 'Hightlight selection on yank',
    pattern = '*',
    callback = function()
        vim.hl.on_yank { higroup = 'IncSearch', timeout = 500 }
    end,
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        io.stdout:write("\027[<0u")
    end
})

-----------------------------------------------------------
-- Load project specific config
-----------------------------------------------------------
local project_config = vim.fn.getcwd() .. "/.nvim.lua"
if vim.fn.filereadable(project_config) == 1 then
    dofile(project_config)
end

-- Disable builtin plugins.
-- NOTE: only guards that actually exist in $VIMRUNTIME are listed. Names such as
-- `loaded_ftplugin`, `loaded_compiler`, `loaded_rplugin` or `loaded_vimball` are
-- not real guard variables -- setting them does nothing.
local disabled_built_ins = {
    "2html_plugin",
    "gzip",
    "netrw",
    "netrwPlugin",
    "matchit",
    "tar",
    "tarPlugin",
    "spellfile_plugin",
    "zip",
    "zipPlugin",
}

for _, plugin in pairs(disabled_built_ins) do
    g["loaded_" .. plugin] = 1
end
