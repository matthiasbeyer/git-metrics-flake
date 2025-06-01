{
  mkMetric,
  pkgs,
  gitMinimal,
  git-metrics,
  ...
}:

attrs@{
  drv,
  pkgs,
  git-metrics,
  metrics ? [ ],
  doPull ? false,
  doCheck ? false,
  doPush ? false,
  ...
}:

let
  toLines = list: pkgs.lib.strings.concatStringsSep "\n" list;
  execMetric =
    m:
    pkgs.lib.getExe (m {
      inherit drv;
    });
in
pkgs.writeShellApplication {
  name = "metric-ci-script";

  runtimeInputs = [
    gitMinimal
    git-metrics
  ];

  text =
    let
      git-metrics = pkgs.lib.getExe attrs.git-metrics;
    in
    ''
      ${pkgs.lib.optionalString doPull ''
        ${git-metrics} pull
      ''}

      ${toLines (builtins.map execMetric metrics)}

      ${pkgs.lib.optionalString doCheck ''
        ${git-metrics} check
      ''}

      ${pkgs.lib.optionalString doPush ''
        ${git-metrics} push
      ''}
    '';
}
