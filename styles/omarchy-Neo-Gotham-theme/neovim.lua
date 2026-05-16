return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#121212",
        dark_bg    = "#0e0e0e",
        darker_bg  = "#090909",
        lighter_bg = "#2a2a2a",

        fg         = "#ffffff",
        dark_fg    = "#bfbfbf",
        light_fg   = "#ffffff",
        bright_fg  = "#ffffff",
        muted      = "#9e9e9e",

        red        = "#ee323f",
        yellow     = "#ee3144",
        orange     = "#f1515c",
        green      = "#f52842",
        cyan       = "#6e74ff",
        blue       = "#5972ff",
        purple     = "#d436dc",
        brown      = "#913137",

        bright_red    = "#ff525c",
        bright_yellow = "#ff5162",
        bright_green  = "#ff4a60",
        bright_cyan   = "#9291ff",
        bright_blue   = "#7c8fff",
        bright_purple = "#ff4eff",

        accent               = "#5972ff",
        cursor               = "#ffffff",
        foreground           = "#ffffff",
        background           = "#121212",
        selection             = "#2a2a2a",
        selection_foreground = "#ffffff",
        selection_background = "#2a2a2a",
      },
    },
    -- set up hot reload
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
      require("aether.hotreload").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
