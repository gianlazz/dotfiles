{ config, pkgs, lib, ... }:

{
  # Essential packages
  home.packages = with pkgs; [
    # Development tools
    neovim
    tmux
    git
    starship
    fzf
    ripgrep
    fd
    bat
    eza
    zoxide

    # System utilities
    htop
    btop
    curl
    wget
    unzip
    tree
    jq

    # Modern CLI tools
    delta         # Better git diff
    tokei         # Code statistics
    bottom        # System monitor
    dust          # Disk usage analyzer
    procs         # Better ps
    lazygit       # Git TUI
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
    PAGER = "less -R";
    LANG = "en_US.UTF-8";
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";  # Replace with your name
    userEmail = "your.email@example.com";  # Replace with your email

    delta = {
      enable = true;
      options = {
        theme = "Catppuccin Mocha";
        line-numbers = true;
        side-by-side = true;
      };
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      cm = "commit -m";
      cam = "commit -am";
    };
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$line_break$character";

      character = {
        success_symbol = "[❯](bold mauve)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        style = "bold blue";
        truncate_to_repo = false;
      };

      git_branch = {
        style = "bold purple";
      };
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
    ];

    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Pane navigation
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Split panes
      bind | split-window -h
      bind - split-window -v
    '';
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable XDG desktop integration
  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;
}