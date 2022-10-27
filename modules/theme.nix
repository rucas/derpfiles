let theme = builtins.fromTOML (builtins.readFile ./themes/gruvbox.toml);
in { inherit theme; }
