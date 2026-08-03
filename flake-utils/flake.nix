{
  description = "Golang Project Template";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      eachSystem =
        systems: fn:
        lib.foldl' (
          acc: system: lib.recursiveUpdate acc (lib.mapAttrs (_: value: { ${system} = value; }) (fn system))
        ) { } systems;

      systems = lib.systems.flakeExposed;
    in
    eachSystem systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          example = pkgs.callPackage ./default.nix { };
          default = self.packages.${pkgs.stdenv.hostPlatform.system}.example;
        };

        devShells = {
          default = pkgs.callPackage ./shell.nix { };
        };
      }
    )
    // {
      overlays.default = final: _: { example = final.callPackage ./default.nix { }; };
    };
}
