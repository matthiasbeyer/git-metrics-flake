{ pkgs }:
{ drv, ... }:

let
  metric = {
    script = pkgs.writeShellApplication {
      name = "flake_last_modified";

      runtimeInputs = [
        pkgs.nix
      ];

      text = ''
        nix flake metadata --json | jq '.lastModified'
      '';
    };
    tags = { };
  };
in
metric
