{
  description = "EvenHub Simulator";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
      rec {
        evenhub-simulator = pkgs.callPackage ./sim-linux-x64.nix { };

        default = evenhub-simulator;

        evenhub-simulator-headless = pkgs.writeShellApplication {
          name = "evenhub-simulator-headless";
          runtimeInputs = [ evenhub-simulator pkgs.xvfb-run ];
          text = ''
            #! ${pkgs.runtimeShell}
            export LIBGL_DRIVERS_PATH=${pkgs.mesa}
            export __EGL_VENDOR_LIBRARY_FILENAMES=${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
            export WEBKIT_DISABLE_COMPOSITING_MODE=1
            exec xvfb-run --auto-display evenhub-simulator "$@"
          '';
        };
      };
  };
}
