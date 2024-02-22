{ ... }: {
  programs.gitui = {
    enable = true;
    keyConfig = ''
      (
        open_help: Some(( code: F(1), modifiers: "")),
        move_left: Some(( code: Char('h'), modifiers: "")),
        move_right: Some(( code: Char('l'), modifiers: "")),
        move_up: Some(( code: Char('k'), modifiers: "")),
        move_down: Some(( code: Char('j'), modifiers: "")),
        popup_up: Some(( code: Char('p'), modifiers: "CONTROL")),
        popup_down: Some(( code: Char('n'), modifiers: "CONTROL")),
        page_up: Some(( code: Char('b'), modifiers: "CONTROL")),
        page_down: Some(( code: Char('f'), modifiers: "CONTROL")),
        home: Some(( code: Char('g'), modifiers: "")),
        end: Some(( code: Char('G'), modifiers: "SHIFT")),
        shift_up: Some(( code: Char('K'), modifiers: "SHIFT")),
        shift_down: Some(( code: Char('J'), modifiers: "SHIFT")),
        edit_file: Some(( code: Char('I'), modifiers: "SHIFT")),
        status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
        diff_reset_lines: Some(( code: Char('u'), modifiers: "")),
        diff_stage_lines: Some(( code: Char('s'), modifiers: "")),
        stashing_save: Some(( code: Char('w'), modifiers: "")),
        stashing_toggle_index: Some(( code: Char('m'), modifiers: "")),
        stash_open: Some(( code: Char('l'), modifiers: "")),
        abort_merge: Some(( code: Char('M'), modifiers: "SHIFT")),
      )
    '';
    # TODO: https://github.com/catppuccin/gitui
    # try to make gruvbox one?
    theme = ''
      (
        selected_tab: Reset,
        command_fg: Black,
        selection_bg: Blue,
        selection_fg: White,
        cmdbar_bg: Blue,
        cmdbar_extra_lines_bg: Blue,
        disabled_fg: DarkGray,
        diff_line_add: Green,
        diff_line_delete: Red,
        diff_file_added: LightGreen,
        diff_file_removed: LightRed,
        diff_file_moved: LightMagenta,
        diff_file_modified: Yellow,
        commit_hash: Magenta,
        commit_time: LightCyan,
        commit_author: Green,
        danger_fg: Red,
        push_gauge_bg: Blue,
        push_gauge_fg: Reset,
        tag_fg: LightMagenta,
        branch_fg: LightYellow,
      )
    '';
  };
}
