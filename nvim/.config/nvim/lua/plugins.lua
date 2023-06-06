vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	use({ "wbthomason/packer.nvim" })

	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
    use ({ 'nvim-tree/nvim-web-devicons' })
	--    use { 'dracula/vim', as = 'dracula' }
	use({ "catppuccin/nvim", as = "catppuccin" })
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use({ "tpope/vim-fugitive" })
	use({ "lewis6991/gitsigns.nvim" })
	use({ "ThePrimeagen/harpoon" })

	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({})
		end,
	})

	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	})

	use({
		"scalameta/nvim-metals",
		requires = { "nvim-lua/plenary.nvim" },
	})

	use({
		"jose-elias-alvarez/null-ls.nvim",
	})

	use({
		"jay-babu/mason-null-ls.nvim",
	})

	use({
		"VonHeikemen/lsp-zero.nvim",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{ "williamboman/mason.nvim" }, -- Optional
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" }, -- Required
			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
			{ "hrsh7th/cmp-buffer" }, -- Optional
			{ "hrsh7th/cmp-path" }, -- Optional
			{ "saadparwaiz1/cmp_luasnip" }, -- Optional
			{ "hrsh7th/cmp-nvim-lua" }, -- Optional

			-- Snippets
			{ "L3MON4D3/LuaSnip" }, -- Required
			{ "rafamadriz/friendly-snippets" }, -- Optional
		},
	})

	use({
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	})
end)
