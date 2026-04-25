{
  lib,
  src,
  stdenvNoCC,
  makeWrapper,
  rofi-wayland,
  fd,
  xdg-utils,
  wl-clipboard,
  coreutils,
  gnugrep,
  gawk,
}:

stdenvNoCC.mkDerivation {
  pname = "ft-nixlaunch";
  version = "2.0.0";

  inherit src;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/ft-nixlaunch/scripts
    mkdir -p $out/share/ft-nixlaunch/themes
    mkdir -p $out/share/applications

    # Default fallback theme (Catppuccin Mocha — module overrides this at HM level)
    cp themes/ft-nixlaunch.rasi $out/share/ft-nixlaunch/themes/

    # Mode scripts
    for script in scripts/file-search.sh scripts/web-search.sh; do
      install -Dm755 "$script" "$out/share/ft-nixlaunch/scripts/$(basename "$script")"
    done

    # Main launcher binary
    install -Dm755 scripts/ft-nixlaunch-launcher.sh $out/bin/ft-nixlaunch

    # Substitute the @out@ placeholder with the real store path
    substituteInPlace $out/bin/ft-nixlaunch \
      --replace-fail "@out@" "$out"

    # Wrap the main launcher with all runtime dependencies on PATH
    wrapProgram $out/bin/ft-nixlaunch \
      --prefix PATH : ${
        lib.makeBinPath [
          rofi-wayland
          fd
          xdg-utils
          wl-clipboard
          coreutils
          gnugrep
          gawk
        ]
      }

    # Wrap mode scripts with a subset of runtime dependencies
    for script in $out/share/ft-nixlaunch/scripts/*.sh; do
      wrapProgram "$script" \
        --prefix PATH : ${
          lib.makeBinPath [
            fd
            xdg-utils
            coreutils
            gnugrep
            gawk
          ]
        }
    done

    # Desktop entry (NoDisplay so it doesn't clutter app menus)
    cat > $out/share/applications/ft-nixlaunch.desktop <<EOF
[Desktop Entry]
Name=ft-nixlaunch
Comment=Modern Rofi application launcher
Exec=$out/bin/ft-nixlaunch
Icon=application-menu
Type=Application
Categories=Utility;
Keywords=launcher;search;run;applications;rofi;
NoDisplay=true
EOF

    runHook postInstall
  '';

  meta = {
    description = "A modern, polished Rofi application launcher for Wayland";
    homepage    = "https://github.com/FT-nixforge/ft-nixlaunch";
    license     = lib.licenses.mit;
    platforms   = lib.platforms.linux;
    mainProgram = "ft-nixlaunch";
  };
}
