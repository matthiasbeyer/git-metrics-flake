{
  mkMetric,
  pkgs,
  gitMinimal,
  git-metrics,
  ...
}:

attrs@{
  pkgs,
  git-metrics,
  metrics ? [ ],
  doPull ? false,
  pullRemote ? null,
  doCheck ? false,
  doPush ? false,
  pushRemote ? null,
  ...
}:

let
  toLines = list: pkgs.lib.strings.concatStringsSep "\n" list;
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
        ${git-metrics} pull ${toString pullRemote}
      ''}

      ${toLines (builtins.map pkgs.lib.getExe metrics)}

      ${pkgs.lib.optionalString doCheck ''
        ${git-metrics} check
      ''}

      ${pkgs.lib.optionalString doPush ''
        ${git-metrics} push ${toString pushRemote}
      ''}
    '';
}
