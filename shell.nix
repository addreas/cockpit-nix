{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage ./default.nix {}

# https://nixos.wiki/wiki/Development_environment_with_nix-shell
# echo "src = $src" && cd $(mktemp -d) && unpackPhase && cd *
# patchPhase
# configurePhase 
# buildPhase 
# checkPhase && installPhase && fixupPhase

# nix-build -E with import <nixpkgs> {}; callPackage ./default.nix {}
