{ mkMetric, ... }:

{
  pkgs,
  git-metrics,
  metrics ? [ ],
  doCheck ? false,
  ...
}:

pkgs.writeShellApplication {
  name = "metric-ci-script";

  text =
    let
      git-metrics = pkgs.lib.getExe git-metrics;
    in
    ''
      ${git-metrics} pull

      ${pkgs.strings.concatStringsSep "\n" (builtins.map (metric: "${metric}") metrics)}

      ${pkgs.lib.optionalString doCheck ''
        ${git-metrics} check
      ''}

      ${git-metrics} push
    '';
}
