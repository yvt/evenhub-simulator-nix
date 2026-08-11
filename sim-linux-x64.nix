# evenhub-simulator for x86_64 Linux
{
  fetchurl,
  stdenv,
  lib,
  nodejs,
  autoPatchelfHook,
  installShellFiles,
  gtk3,
  webkitgtk_4_1,
  alsa-lib,
  xvfb-run,
  ...
}:

let
  generateCompletion = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd evenhub-simulator \
      --bash <(xvfb-run -n 120 $out/bin/evenhub-simulator --completions bash) \
      --zsh <(xvfb-run -n 121 $out/bin/evenhub-simulator --completions zsh) \
      --fish <(xvfb-run -n 122 $out/bin/evenhub-simulator --completions fish)
  '';
in
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
    installShellFiles
    xvfb-run
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

  preFixup = ''
    _generateCompletion() {
      ${generateCompletion}
    }
    postFixupHooks+=(_generateCompletion)
  '';

}
