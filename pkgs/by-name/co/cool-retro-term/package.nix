{ lib
, stdenv
, fetchFromGitHub
, qt6
, nixosTests
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cool-retro-term";
  version = "2.0.0-beta2";

  src = fetchFromGitHub {
    owner = "Swordfish90";
    repo = "cool-retro-term";
    tag = finalAttrs.version;
    hash = "sha256-WCiQ+WTZVE3Cf6RWwD7BknkPTsXHordxcdq+HppQZ2Y=";
    fetchSubmodules = true;
  };

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qt5compat
  ];

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  installFlags = [ "INSTALL_ROOT=$(out)" ];

  qtWrapperArgs = [
    "--prefix NIXPKGS_QT6_QML_IMPORT_PATH : ${placeholder "out"}/lib/qt-6/qml"
  ];

  preFixup =
    ''
      mkdir -p $out/lib/qt-6/qml
      find $out/nix/store -name "QMLTermWidget" -type d | while read src; do
        cp -r "$src" $out/lib/qt-6/qml/
      done
      rm -rf $out/nix

      mv $out/usr/share $out/share
      mv $out/usr/bin $out/bin
      rmdir $out/usr
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      ln -s $out/bin/cool-retro-term.app/Contents/MacOS/cool-retro-term $out/bin/cool-retro-term
    '';

  passthru.tests.test = nixosTests.terminal-emulators.cool-retro-term;

  meta = {
    description = "Terminal emulator which mimics the old cathode display";
    longDescription = ''
      cool-retro-term is a terminal emulator which tries to mimic the look and
      feel of the old cathode tube screens. It has been designed to be
      eye-candy, customizable, and reasonably lightweight.
    '';
    homepage = "https://github.com/Swordfish90/cool-retro-term";
    license = lib.licenses.gpl3Plus;
    platforms = with lib.platforms; linux ++ darwin;
    maintainers = [ ];
    mainProgram = "cool-retro-term";
  };
})
