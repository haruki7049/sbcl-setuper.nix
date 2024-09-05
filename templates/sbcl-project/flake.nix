{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        pname = "sbcl-project";
        version = "dev";
        src = ./.;

        sbcl-runtime = pkgs.sbcl.withPackages (ps: [
          # Write your dependencies
          #ps.woo
        ]);

        sbcl-project = sbcl-runtime.buildASDFSystem rec {
          inherit pname version src;
        };

        sbcl-output = sbcl-runtime.withPackages (ps: [ sbcl-project ]);
      in
      {
        formatter = treefmtEval.config.build.wrapper;

        packages = {
          inherit sbcl-output;
          default = sbcl-output;
        };

        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            # Nix
            pkgs.nil
            pkgs.nixpkgs-fmt
          ];

          shellHook = ''
            export PS1="\n[nix-shell:\w]$ "
          '';
        };
      }
    );
}
