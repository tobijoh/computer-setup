require 'plugins'

vim.g.mapleader = ' '
vim.cmd('filetype plugin on')

require("telescope").setup {
    extensions = {
        file_browser = {
            theme = "ivy",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true
        }
    }
}

require("telescope").load_extension "file_browser"

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- open file_browser with the path of the current buffer
vim.api.nvim_set_keymap("n", "<space>fb", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", {
    noremap = true
})

vim.cmd("colorscheme nordfox")

require("indent_blankline").setup {
    show_current_context = true,
    show_current_context_start = true
}

require('mini.cursorword').setup()
require('mini.pairs').setup()
