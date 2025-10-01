{ callPackage, mkMetric, ... }:

{
  binary_size = mkMetric {
    name = "binary-size";
    generator = callPackage ./binary_size.nix { };
  };

  flake_last_modified = mkMetric {
    name = "flake_last_modified";
    generator = callPackage ./flake_last_modified.nix { };
  };
}
