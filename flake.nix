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
            firefox
            google-chrome
            glib
            nspr
            nss
            gtk3
            xorg.libX11
            xorg.libxcb
            xorg.libXcomposite
            xorg.libXcursor
            xorg.libXdamage
            xorg.libXext
            xorg.libXfixes
            freetype
            xorg.libXrender
            xorg.libXi
            fontconfig
            libdbusmenu
            libdbusmenu-gtk3
            glib
            dbus
            dbus-glib
            cairo
            pango
            harfbuzz
            atk
            gdk-pixbuf
            xorg.libXt
            libdrm
            cups
            xorg.libXrandr
            expat
            libxkbcommon
            xorg.libxshmfence
            atk
            xdg-utils
            nodejs
            jre
          ];
          extraBuildCommands = ''
            chmod +w usr/bin
            ln -sr usr/bin/google-chrome-stable usr/bin/google-chrome
          '';
          profile = ''
            export PS1="\n\[$(tput setaf 2)\]\w ☯️ \n\[$(tput setaf 4)\]\\$\[$(tput sgr0)\] "
          '';
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [ fhs pkgs.nodejs ];
          shellHook = ''
            export PATH=$PATH:$(npm bin)
            export XDG_DATA_DIRS=$XDG_DATA_DIRS:/etc/profiles/per-user/$USER/share
          '';
        };
      }
    );
}
