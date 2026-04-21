{
  lib,
  stdenvNoCC,
  makeWrapper,
  rofi,
  fd,
  xdg-utils,
  wl-clipboard,
  coreutils,
  gnugrep,
  gawk,
}:

stdenvNoCC.mkDerivation {
  pname = "ft-nixlaunch";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/ft-nixlaunch/scripts
    mkdir -p $out/share/ft-nixlaunch/themes
    mkdir -p $out/share/applications

    # Default theme
    cp themes/ft-nixlaunch.rasi $out/share/ft-nixlaunch/themes/

    # Mode scripts
    for script in scripts/file-search.sh scripts/web-search.sh; do
      install -Dm755 "$script" "$out/share/ft-nixlaunch/scripts/$(basename "$script")"
    done

    # Main launcher
    install -Dm755 scripts/ft-nixlaunch-launcher.sh $out/bin/ft-nixlaunch

    # Substitute store paths (only the launcher references @out@)
    substituteInPlace $out/bin/ft-nixlaunch \
      --replace-fail "@out@" "$out"

    # Wrap with runtime dependencies
    wrapProgram $out/bin/ft-nixlaunch \
      --prefix PATH : ${
        lib.makeBinPath [
          rofi
          fd
          xdg-utils
          wl-clipboard
          coreutils
          gnugrep
          gawk
        ]
      }

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

    # Desktop entry
    {
      echo "[Desktop Entry]"
      echo "Name=ft-nixlaunch"
      echo "Comment=Modern application launcher"
      echo "Exec=$out/bin/ft-nixlaunch"
      echo "Icon=application-menu"
      echo "Type=Application"
      echo "Categories=Utility;"
      echo "Keywords=launcher;search;run;applications;"
      echo "NoDisplay=true"
    } > $out/share/applications/ft-nixlaunch.desktop

    runHook postInstall
  '';

  meta = {
    description = "A modern, polished Rofi application launcher for Wayland";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "ft-nixlaunch";
  };
}
