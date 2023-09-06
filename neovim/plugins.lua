local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'editorconfig/editorconfig-vim'
Plug('nvim-treesitter/nvim-treesitter', {
    ['do'] = ':TSUpdate'
})

Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', {
    tag = '0.1.x'
})

Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'EdenEast/nightfox.nvim'
Plug 'preservim/nerdcommenter'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'echasnovski/mini.nvim'

vim.call('plug#end')
