{ ... }:
{
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
    theme = ''
      (
        selected_tab: Some("#ebdbb2"),
        command_fg: Some("#ebdbb2"),
        command_bg: Some("#3c3836"),
        selection_bg: Some("#665c54"),
        selection_fg: Some("#ebdbb2"),
        cmdbar_bg: Some("#282828"),
        cmdbar_extra_lines_bg: Some("#504945"),
        disabled_fg: Some("#928374"),
        diff_line_add: Some("#b8bb26"),
        diff_line_delete: Some("#fb4934"),
        diff_file_added: Some("#b8bb26"),
        diff_file_removed: Some("#fb4934"),
        diff_file_moved: Some("#d3869b"),
        diff_file_modified: Some("#fabd2f"),
        commit_hash: Some("#d3869b"),
        commit_time: Some("#83a598"),
        commit_author: Some("#b8bb26"),
        danger_fg: Some("#fb4934"),
        push_gauge_bg: Some("#458588"),
        push_gauge_fg: Some("#ebdbb2"),
        tag_fg: Some("#fe8019"),
        branch_fg: Some("#8ec07c"),
      )
    '';
  };
}
