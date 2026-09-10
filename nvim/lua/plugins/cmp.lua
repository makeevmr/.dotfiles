local cmp = require 'cmp'

cmp.setup({
    window = {
        completion = cmp.config.window.bordered({
            border = 'rounded',
            winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSelection,Search:None',
            scrollbar = true,
        }),
        documentation = cmp.config.window.bordered({
            border = 'rounded',
            winhighlight = 'Normal:CmpDocNormal,FloatBorder:CmpDocBorder',
        }),
    },
    formatting = {
        fields = { "abbr", "kind" }, -- Name first, then kind
        format = function(_, vim_item)
            -- Just keep the kind text, no icons
            vim_item.kind = vim_item.kind -- Keep as-is (Method, Function, Variable, etc.)
            vim_item.menu = nil           -- Remove menu/signature
            return vim_item
        end
    },
    mapping = {
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
        {
            name = 'nvim_lsp',
            entry_filter = function(entry)
                return cmp.lsp.CompletionItemKind.Snippet ~= entry:get_kind()
            end
        },
    }, {
        { name = 'buffer' },
    }),
})

-- Custom highlight groups
vim.api.nvim_set_hl(0, 'CmpNormal', { bg = '#1f2335', fg = '#c0caf5' })
vim.api.nvim_set_hl(0, 'CmpBorder', { bg = '#1f2335', fg = '#3b4261' })
vim.api.nvim_set_hl(0, 'CmpSelection', { bg = '#33467c', fg = '#c0caf5' })
vim.api.nvim_set_hl(0, 'CmpDocNormal', { bg = '#1f2335', fg = '#c0caf5' })
vim.api.nvim_set_hl(0, 'CmpDocBorder', { bg = '#1f2335', fg = '#3b4261' })
