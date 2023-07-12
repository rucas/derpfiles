{ ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      italic-text = "always";
      map-syntax = [
        "**/.zfuncs/*:Bourne Again Shell (bash)"
        "**/workplace/**/**/Config:Perl"
        "**/workplace/**/packageInfo:Perl"
      ];
    };
  };
}
