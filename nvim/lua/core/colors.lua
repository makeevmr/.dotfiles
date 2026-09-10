vim.o.background = "dark"

require("gruvbox").setup({
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
        strings = false,
        comments = false,
        operators = false,
        folds = false,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true,
    contrast = "hard",
    palette_overrides = {
        dark0_hard = "#000000",
    },
    overrides = {
        ["@lsp.type.property.cpp"] = { fg = "#89C07C" },
    },
    dim_inactive = false,
    transparent_mode = false,
})

require("tokyonight").setup({
    styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = { italic = false },
        variables = { italic = false },
    },
    on_colors = function(colors)
        colors.bg = "#000000"
    end,
    on_highlights = function(highlights, colors)
        for _, group in ipairs({
            "NeoTreeNormal",
            "NeoTreeNormalNC",
            "NeoTreeEndOfBuffer",
        }) do
            highlights[group] = highlights[group] or {}
            highlights[group].bg = colors.bg
        end

        highlights.ColorColumn = { bg = colors.bg_highlight }
    end,
})

-- Tokyo Night remains the active colorscheme.
vim.cmd.colorscheme("tokyonight-night")
