{ pkgs, ... }: {
  programs.tmux = {
    aggressiveResize = true;
    enable = true;
    keyMode = "vi";
    prefix = "C-a";
    mouse = true;
    terminal = "tmux-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    sensibleOnTop = false;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.mode-indicator;
        extraConfig = ''
          set -g @mode_indicator_prefix_prompt      "\uf46e WAIT" # …
          set -g @mode_indicator_copy_prompt        "\uf68e COPY"
          set -g @mode_indicator_sync_prompt        "\uf9e5 SYNC"
          set -g @mode_indicator_empty_prompt       "  #S " #alts: (\uf490)﬿
          set -g @mode_indicator_prefix_mode_style  "bg=blue,fg=black"
          set -g @mode_indicator_copy_mode_style    "bg=yellow,fg=black"
          set -g @mode_indicator_sync_mode_style    "bg=red,fg=black"
          set -g @mode_indicator_empty_mode_style   "bg=cyan,fg=black"
        '';
      }
      #{
      #  plugin = tmuxPlugins.resurrect;
      #  extraConfig = ''
      #    set -g @resurrect-processes "'~vi->nvim'"
      #  '';
      #}
      #{
      #  plugin = tmuxPlugins.continuum;
      #  extraConfig = ''
      #    set -g @continuum-restore 'on'
      #    set -g @continuum-save-interval '5'
      #  '';
      #}
      # { plugin = tmuxPlugins.tmux-thumbs; }
    ];
    extraConfig = ''
      # stop messing with nvim c-l window nav
      unbind-key C-l

      if 'infocmp -x alacritty > /dev/null 2>&1' 'set -g default-terminal "alacritty"'
      set -ag terminal-overrides ",alacritty:RGB"

      # set update frequencey (default 15 seconds)
      set -g status-interval 5

      # status line theme colors
      set -g status-position top

      # left window list
      set -g status-justify centre
      set -g status-style bg=#2b2b2b,fg=#d4be98

      # status left styles
      # alts:   ﬿
      set -g status-left "#[fg=#d4be98,bg=#2b2b2b,bold]\
      #{?window_zoomed_flag,#[bg=colour39],}\
      #{?client_prefix,#[fg=#2b2b2b#,bg=#7daea3],}\
      #{?pane_in_mode,#[fg=#2b2b2b#,bg=#e78a4e],}\
      ﬿ #S"
      set -g status-left-length 200

      # status right styles
      # NOTE: https://github.com/tmux-plugins/tmux-continuum/issues/48#issuecomment-603476019
      # set -g status-right '#(whoami)@#H #(${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh)'
      set -g status-right-length 100
      set -g status-right '%Y-%m-%d %H:%M #{tmux_mode_indicator}'

      # inactive window style
      set -g window-status-style fg=#928374,bg=default
      set -g window-status-format ' #W '

      # active window style
      set -g window-status-current-style fg=black,bg=#ea6962
      set -g window-status-current-format ' #W '

      # focus events for nvim+tmux happiness
      set -g focus-events on

      # keep windows numbering linear
      set -g renumber-windows on

      # jump back to previous window
      bind-key Space last-window

      # C-a n to jump to next window
      # C-a p to jump to previous window

      # open new window in current path
      bind-key c new-window -c "#{pane_current_path}"

      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1


      bind-key Tab display-menu -T "#[align=centre]Sessions" \
        "Switch" . 'choose-session -Zw' Last l "switch-client -l" "" \
        Exit q detach

      bind-key R source-file ~/.config/tmux/tmux.conf \; display-message "~/.config/tmux/tmux.conf reloaded"
    '';
  };
}
