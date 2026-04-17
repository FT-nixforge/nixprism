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
  pname = "nixprism";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/nixprism/scripts
    mkdir -p $out/share/nixprism/themes
    mkdir -p $out/share/applications

    # Default theme
    cp themes/nixprism.rasi $out/share/nixprism/themes/

    # Mode scripts
    for script in scripts/file-search.sh scripts/web-search.sh; do
      install -Dm755 "$script" "$out/share/nixprism/scripts/$(basename "$script")"
    done

    # Main launcher
    install -Dm755 scripts/nixprism-launcher.sh $out/bin/nixprism

    # Substitute store paths (only the launcher references @out@)
    substituteInPlace $out/bin/nixprism \
      --replace-fail "@out@" "$out"

    # Wrap with runtime dependencies
    wrapProgram $out/bin/nixprism \
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

    for script in $out/share/nixprism/scripts/*.sh; do
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
      echo "Name=nixprism"
      echo "Comment=Modern application launcher"
      echo "Exec=$out/bin/nixprism"
      echo "Icon=application-menu"
      echo "Type=Application"
      echo "Categories=Utility;"
      echo "Keywords=launcher;search;run;applications;"
      echo "NoDisplay=true"
    } > $out/share/applications/nixprism.desktop

    runHook postInstall
  '';

  meta = {
    description = "A modern, polished Rofi application launcher for Wayland";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "nixprism";
  };
}
