# NOTE: https://www.fbrs.io/nix-overlays/
{ inputs, ... }: {
  alacritty = (final: prev: {
    alacritty = prev.alacritty.overrideAttrs (drv: rec {
      src = inputs.alacritty;
      cargoDeps = drv.cargoDeps.overrideAttrs (prev.lib.const {
        inherit src;
        outputHash = "sha256-THgd6A7elphuiADJrEnO65Nf0CkySvJQjVV9Q2w5T0Y=";
      });
      postInstall = (if prev.stdenv.isDarwin then ''
        mkdir $out/Applications
        cp -r extra/osx/Alacritty.app $out/Applications
        ln -s $out/bin $out/Applications/Alacritty.app/Contents/MacOS
      '' else ''
        install -D extra/linux/Alacritty.desktop -t $out/share/applications/
        install -D extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/
        install -D extra/logo/compat/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg

        # patchelf generates an ELF that binutils' "strip" doesn't like:
        #    strip: not enough room for program headers, try linking with -N
        # As a workaround, strip manually before running patchelf.
        $STRIP -S $out/bin/alacritty

        patchelf --set-rpath "${
          prev.lib.makeLibraryPath prev.rpathLibs
        }" $out/bin/alacritty
      '') + ''

        installShellCompletion --zsh extra/completions/_alacritty
        installShellCompletion --bash extra/completions/alacritty.bash
        installShellCompletion --fish extra/completions/alacritty.fish

        install -dm 755 "$out/share/man/man1"
        # NOTE: this fails on alacritty master...why?
        # gzip -c extra/alacritty.man > "$out/share/man/man1/alacritty.1.gz"
        # gzip -c extra/alacritty-msg.man > "$out/share/man/man1/alacritty-msg.1.gz"

        # install -Dm 644 alacritty.yml $out/share/doc/alacritty.yml

        install -dm 755 "$terminfo/share/terminfo/a/"
        tic -xe alacritty,alacritty-direct -o "$terminfo/share/terminfo" extra/alacritty.info
        mkdir -p $out/nix-support
        echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
      '';
    });
  });
  yabai = (final: prev: { yabai = prev.callPackage ../pkgs/yabai { }; });
  vimPlugins = (final: prev: {
    vimPlugins = prev.vimPlugins
      // final.callPackage ../pkgs/vim-plugins { inherit inputs; };
  });
}
