-- With help of (https://www.youtube.com/watch?v=4PzSNN45tcA&t=453s)
-- Core

require('core.config')   -- Basic options
require('core.mappings') -- Keymaps
require('core.plugins')  -- Lazyvim for plugins installation
require('core.colors')   -- Tokyo Night color scheme

-- Plugins
require('plugins.autopairs')  -- Autopair brackets support
require('plugins.cmp')        -- Autocompletion
require('plugins.comment')    -- Comments support
require('plugins.gitsigns')   -- Git support
require('plugins.harpoon')    -- For better file navigation
require('plugins.navic')      -- Breadcrumbs for statusline
require('plugins.mason')      -- For easy lsp installation
require('plugins.lsp')        -- For errors highlighting, go to defenition, references, format and so on
require('plugins.lualine')    -- Status line support
require('plugins.surround')   -- Better work with brackets
require('plugins.neotree')    -- Files tree
require('plugins.telescope')  -- File finder, grep, current buffers
require('plugins.treesitter') -- Better syntax highlighting
-- require('plugins.ibl')        -- Indent guides
