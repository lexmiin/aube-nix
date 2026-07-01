{
  description = "Nix flake for aube";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    overlay = final: _prev: {
      aube = final.callPackage ./package.nix {};
    };

    pkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [overlay];
      };
  in {
    overlays.default = overlay;

    packages = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.aube;
      aube = pkgs.aube;
    });

    apps = forAllSystems (system: {
      default = self.apps.${system}.aube;
      aube = {
        type = "app";
        program = "${self.packages.${system}.aube}/bin/aube";
      };
      aubr = {
        type = "app";
        program = "${self.packages.${system}.aube}/bin/aubr";
      };
      aubx = {
        type = "app";
        program = "${self.packages.${system}.aube}/bin/aubx";
      };
    });

    checks = forAllSystems (system: {
      aube = self.packages.${system}.aube;
    });

    formatter = forAllSystems (system: let
      pkgs = pkgsFor system;
    in
      pkgs.writeShellApplication {
        name = "aube-nix-fmt";
        runtimeInputs = [pkgs.alejandra];
        text = ''
          if [ "$#" -eq 0 ]; then
            alejandra .
          else
            alejandra "$@"
          fi
        '';
      });

    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          gh
          jq
          nix-prefetch-github
          python3
        ];
      };
    });
  };
}
