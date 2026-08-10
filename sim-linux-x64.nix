# evenhub-simulator for x86_64 Linux
{
  fetchurl,
  stdenv,
  nodejs,
  autoPatchelfHook,
  gtk3,
  webkitgtk_4_1,
  alsa-lib,
  ...
}:

stdenv.mkDerivation rec {
  pname = "evenhub-simulator";
  version = "0.8.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@evenrealities/sim-linux-x64/-/sim-linux-x64-${version}.tgz";
    hash = "sha256-8npupMzZnuM/vs9giegnyZ1TElnOoCdqQPSEPyIfp+0=";
  };

  nativeBuildInputs = [
    nodejs
    autoPatchelfHook
  ];

  buildInputs = [
    gtk3
    webkitgtk_4_1
    alsa-lib
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Copy the prebuilt Tauri application binary
    mkdir -p $out/bin
    cp bin/evenhub-simulator $out/bin/

    runHook postInstall
  '';
}
