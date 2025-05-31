{
  description = "A flake for building git metrics with git-metrics";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };

        src = ./.;

        formatting =
          let
            treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs (
              { pkgs, ... }:
              {
                projectRootFile = "flake.nix";

                settings.excludes = [
                  "*.lock"
                  ".envrc"
                  ".gitignore"
                  ".gitlint"
                ];

                programs = {
                  nixfmt.enable = true;
                  mdformat.enable = true;
                };
              }
            );
          in
          {
            formatter = treefmtEval.config.build.wrapper;
            check = treefmtEval.config.build.check src;
          };

      in
      {
        inherit (formatting) formatter;
        checks = {
          inherit (formatting) check;
        };

        lib = rec {
          mkMetric = import ./mk_metric.nix { };

          mkCiScript = import ./mk_metric_ci_script.nix {
            inherit mkMetric;
          };

          metrics = import ./metrics {
            inherit mkMetric;
          };
        };

        packages.git-metrics = pkgs.callPackage ./git-metrics.nix { };
      }
    );
}
