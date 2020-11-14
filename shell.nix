let
  sources = import ./nix/sources.nix;
  pkgs = import sources.dapptools {};
in
  pkgs.mkShell {
    buildInputs = [
      pkgs.dapp
      pkgs.hevm
      pkgs.bashInteractive
    ];
  }
