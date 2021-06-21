{
  description = "Tests deps";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        fhs = pkgs.buildFHSUserEnv {
          name = "acceptance-env";
          targetPkgs = pkgs: with pkgs; [
            jre
            firefox
            google-chrome
            glib
            nspr
            nss
            xorg.libX11
            xorg.libxcb
            nodejs
          ];
          extraBuildCommands = ''
            chmod +w usr/bin
            ln -sr usr/bin/google-chrome-stable usr/bin/google-chrome
          '';
          profile = ''
            export PS1="\n\[$(tput setaf 2)\]\w ☯️ \n\[$(tput setaf 4)\]\\$\[$(tput sgr0)\] "
          '';
        };
        script = pkgs.writeScript "mklink" ''
          #!${pkgs.runtimeShell}
          chrome_wrapper=$(which chromium)
          chrome_path=$(nix path-info "$chrome_wrapper")
          chrome_binary=$chrome_path/bin/chromium

          ln -sf "$chrome_binary" ${"$HOME/.cache/ms-playwright/chromium-*/chrome-linux/chrome"}
        '';
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [ fhs pkgs.nodejs ];
          shellHook = ''
            export PATH=$PATH:$(npm bin)
            export XDG_DATA_DIRS=$XDG_DATA_DIRS:/etc/profiles/per-user/$USER/share
            ${script}
          '';
        };
      }
    );
}
