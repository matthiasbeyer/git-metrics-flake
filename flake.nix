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

        callPackage = pkgs.lib.callPackageWith (
          pkgs
          // inputs.self.packages."${system}"
          // {
            inherit callPackage;

            # Inherit our "lib" with a more readable name for importing it into the VMtests
            gitMetricsLib = inputs.self.lib."${system}";
          }
        );

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

        tests = callPackage ./tests { };
      in
      {
        inherit (formatting) formatter;
        checks = {
          inherit (formatting) check;
          inherit (tests) simple generate-metric-binary-size;
        };

        lib = rec {
          mkMetric = callPackage ./mk_metric.nix { };

          mkCiScript = callPackage ./mk_metric_ci_script.nix {
            inherit mkMetric;
          };

          metrics = callPackage ./metrics {
            inherit mkMetric;
          };
        };

        packages =
          let
            mkCiScript = inputs.self.lib."${system}".mkCiScript;
            ms = inputs.self.lib."${system}".metrics;
          in
          {
            git-metrics = pkgs.callPackage ./git-metrics.nix { };

            # For won CI, do not use
            ci-script = mkCiScript {
              inherit pkgs;
              inherit (inputs.self.packages."${system}") git-metrics;
              drv = inputs.self.packages."${system}".git-metrics;

              metrics = [
                ms.binary_size
                ms.flake_last_modified
              ];
            };
          };

      }
    );
}
