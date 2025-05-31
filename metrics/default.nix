{ mkMetric, ... }:

{
  binary_size = mkMetric {
    name = "binary-size";
    generator = ./binary_size.nix;
  };
}
