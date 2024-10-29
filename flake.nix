{
  description = "lustre development";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = lib.systems.flakeExposed;
      eachDefaultSystem = f: builtins.foldl' lib.attrsets.recursiveUpdate { }
        (map f systems);
    in
    eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.${system}.default = pkgs.mkShellNoCC {
          packages = [
            pkgs.erlang_26
            pkgs.gleam
            pkgs.inotify-tools
            pkgs.rebar3
            (pkgs.writeShellApplication {
              name = "start-dev";
              text = ''
                gleam run -m lustre/dev start
              '';
            })
          ];
        };
      }
    );
}
