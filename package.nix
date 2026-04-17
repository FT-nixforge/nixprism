{
  lib,
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
  pname = "prism";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/prism/scripts
    mkdir -p $out/share/prism/themes
    mkdir -p $out/share/applications

    # Default theme
    cp themes/prism.rasi $out/share/prism/themes/

    # Mode scripts
    for script in scripts/file-search.sh scripts/web-search.sh; do
      install -Dm755 "$script" "$out/share/prism/scripts/$(basename "$script")"
    done

    # Main launcher
    install -Dm755 scripts/prism-launcher.sh $out/bin/prism

    # Substitute store paths
    substituteInPlace $out/bin/prism \
      --replace-fail "@out@" "$out"

    for script in $out/share/prism/scripts/*.sh; do
      substituteInPlace "$script" \
        --replace-fail "@out@" "$out"
    done

    # Wrap with runtime dependencies
    wrapProgram $out/bin/prism \
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

    for script in $out/share/prism/scripts/*.sh; do
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
      echo "Name=Prism"
      echo "Comment=Modern application launcher"
      echo "Exec=$out/bin/prism"
      echo "Icon=application-menu"
      echo "Type=Application"
      echo "Categories=Utility;"
      echo "Keywords=launcher;search;run;applications;"
      echo "NoDisplay=true"
    } > $out/share/applications/prism.desktop

    runHook postInstall
  '';

  meta = {
    description = "A modern, polished Rofi application launcher for Wayland";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "prism";
  };
}
