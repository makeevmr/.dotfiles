-- Tokyo Night cyan for current scope highlighting
vim.api.nvim_set_hl(0, 'IblScope', { fg = "#7dcfff" })

require("ibl").setup({
    -- Show scope lines in default gray color
    indent = {
        char = "▏",
    },
    scope = {
        enabled = true,
        char = "▏",
        highlight = "IblScope",  -- Current scope in aqua
        show_start = false,  -- No top horizontal line
        show_end = false,    -- No bottom horizontal line
        show_exact_scope = true,  -- Only highlight the exact scope
    },
})
