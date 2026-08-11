# Minimal example EvenHub app
{
  buildNpmPackage,
  cacert,
  fetchNpmDeps,
  fetchFromGitHub,
  nodejs,
}:

let
  src = fetchFromGitHub {
    owner = "even-realities";
    repo = "evenhub-templates";
    rev = "8cb01354f5ee914c5fab97d06e6d13b28eeb5815";
    hash = "sha256-uuHsJCIwM1FkVyxgiBb05nvofwgOqw/JUStAhXfchhI=";
  };
  sourceRoot = "source/minimal";
in
buildNpmPackage {
  name = "evenhub-template-minimal";
  inherit src sourceRoot;
  npmDeps = fetchNpmDeps {
    inherit src sourceRoot;
    hash = "sha256-56tlkPICzwBleBBRcCdxSXaJNlCOgdlmAjxhrkSOWGA=";
    nativeBuildInputs = [
      cacert
      nodejs
    ];
    postPatch = ''
      export HOME=$TMPDIR SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      npm install --package-lock-only --ignore-scripts
    '';
  };
  postPatch = "cp $npmDeps/package-lock.json .";
  installPhase = "mkdir $out; cp -r dist/. $out/";
}
