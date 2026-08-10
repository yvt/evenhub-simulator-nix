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
      };
  };
}
