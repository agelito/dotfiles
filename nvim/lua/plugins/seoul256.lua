return {
  'shaunsingh/seoul256.nvim',
  priority = 1000,
  init = function()
    vim.cmd.colorscheme 'seoul256'
    vim.cmd.hi 'Comment gui=none'
  end,
  opts = {},
}
