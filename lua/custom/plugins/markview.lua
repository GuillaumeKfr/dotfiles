return {
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    opts = {
      preview = {
        enable = true,
        enable_hybrid_mode = true,
        modes = { 'n', 'no', 'c' },
        hybrid_modes = { 'n' },
        icon_provider = 'devicons',
      },
    },
  },
}
