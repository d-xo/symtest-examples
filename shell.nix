let
  pkgs = import (builtins.fetchTarball {
    url = https://github.com/dapphub/dapptools/archive/09c30f2473a121abf118aa6b05d5c9d66ec4f5c3.tar.gz;
    sha256 = "0jykr6xrhphq0yfwqp37amjyqk25lzxdkh7i0in9bhvpkrryn6k0";
  }) {};
in
  pkgs.mkShell {
    buildInputs = [
      pkgs.dapp
      pkgs.hevm
      pkgs.bashInteractive
    ];
  }
