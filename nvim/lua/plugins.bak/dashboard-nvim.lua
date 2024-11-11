return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      theme = 'doom',
      config = {
        week_header = {
          enable = 'true',
        },
        center = {
          {
            desc = 'Welcome, happy hacking!',
            desc_hl = 'String',
          },
        },
      },
      change_to_vcs_root = 'true',
      shortcut_type = 'letter',
    }
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
