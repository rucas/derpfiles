{ pkgs, theme, ... }: {
  programs.tmux = {
    aggressiveResize = true;
    disableConfirmationPrompt = true;
    enable = true;
    keyMode = "vi";
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;
    terminal = "tmux-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    sensibleOnTop = false;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-processes "'~vi->nvim'"
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5'
        '';
      }
      { plugin = tmuxPlugins.tmux-thumbs; }
    ];
    extraConfig = ''
      if 'infocmp -x alacritty > /dev/null 2>&1' 'set -g default-terminal "alacritty"'
      set -ag terminal-overrides ",alacritty:RGB"

      # set update frequencey (default 15 seconds)
      set -g status-interval 5

      # status line on the top
      set -g status-position top

      # theme color variables
      set -g @THM_FG      "${theme.colors.primary.other_foreground}"
      set -g @THM_BG      "${theme.colors.primary.other_background}"
      set -g @THM_BLK     "${theme.colors.primary.dark1}"
      set -g @THM_BRW     "${theme.colors.bright.black}"
      set -g @THM_GRY     "${theme.colors.normal.dark_grey}"
      set -g @THM_ORG     "${theme.colors.primary.orange}"
      set -g @THM_RD      "${theme.colors.primary.red}"

      set -g @THM_BRD_FG  "${theme.colors.normal.dark_grey}"

      # adds a border seperator for status line
      setw -g pane-border-status top
      setw -g pane-border-format ""
      setw -g pane-active-border-style "fg=#{@THM_GRY}"

      # left window list
      set -g status-justify left
      set -g status-style "bg=#{@THM_BG},fg=#{@THM_FG}"

      # status left styles
      set -g status-left "#[bg=#{@THM_BG},fg=#{@THM_FG},bold]\
      #{?window_zoomed_flag,#[bg=colour39],}\
      #{?client_prefix,#[fg=#7daea3],}\
      #{?pane_in_mode,#[fg=#2b2b2b#,bg=#e78a4e],}\
       ﬿ #S ⋮ "
      set -g status-left-length 200

      # status right styles
      # NOTE: https://github.com/tmux-plugins/tmux-continuum/issues/48#issuecomment-603476019
      set -g status-right '#[bg=#{@THM_BG},fg=#{@THM_FG}] \
      #(TZ="America/Los_Angeles" date +"%%H:%%M") \
      (UTC #(TZ=GMT date +"%%H:%%M"))  \
      #(gitmux -cfg $HOME/.config/gitmux/gitmux.conf "#{pane_current_path}")\
      #(${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh)'
      set -g status-right-length 100

      # inactive window style
      set -g window-status-style "bg=#{@THM_BLK},fg=#{@THM_BRW}"
      set -g window-status-format '  #W  '

      # active window style
      set -g window-status-current-style "bg=#{@THM_BLK},fg=#{@THM_RD}"
      set -g window-status-current-format '  #W  '

      # message command style
      set -g message-style "bg=#{@THM_BG},fg=#{@THM_FG}"

      # highlight window when it has new activity
      set -g monitor-activity on

      # dont rename window without my permission...
      set -g allow-rename off

      # activity window style
      setw -g window-status-activity-style fg=yellow,bg=red

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

      bind-key R source-file ~/.config/tmux/tmux.conf \; display-message " 󰑓 tmux reloaded"
    '';
  };
}
