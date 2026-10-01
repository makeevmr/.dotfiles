local gitsigns = require('gitsigns')

gitsigns.setup({
    on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', gitsigns.preview_hunk, {
            buffer = bufnr,
            silent = true,
            desc = 'Preview Git hunk at cursor',
        })
        vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk, {
            buffer = bufnr,
            silent = true,
            desc = 'Reset Git hunk at cursor',
        })
    end,
})
