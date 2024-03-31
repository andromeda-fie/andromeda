{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    mkShell = pkgs: let
      inherit (pkgs.beam.interpreters) erlangR26;
      inherit (pkgs.beam) packagesWith;
      beam = packagesWith erlangR26;
    in
      pkgs.mkShell {
        name = "konta-shell";
        packages = with pkgs;
          [beam.elixir_1_16 gnumake gcc openssl zlib postgresql]
          ++ lib.optional stdenv.isLinux [
            inotify-tools
            gtk-engine-murrine
          ]
          ++ lib.optional stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.CoreFoundation
          ];
      };

    linux-pkgs = import nixpkgs {system = "x86_64-linux";};
    darwin-pkgs = import nixpkgs {system = "aarch64-darwin";};
  in {
    devShells = {
      aarch64-darwin.default = mkShell darwin-pkgs;
      x86_64-linux.default = mkShell linux-pkgs;
    };
  };
}
