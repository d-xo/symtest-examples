let
  sources = import ./nix/sources.nix;
  pkgs = import sources.dapptools {};
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      dapp
      hevm
      bashInteractive
      solc-static-versions.solc_0_7_5
    ];
    DAPP_SOLC="solc-0.7.5";
  }
