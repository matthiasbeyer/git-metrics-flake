{
  pkgs,
  git-metrics,
  gitMinimal,
  ...
}:

{
  name,
  generator,
  ...
}:

{ drv }:

let
  metric = generator { inherit drv; };
  tag_flags = pkgs.lib.attrsets.foldlAttrs (
    acc: key: value:
    "${acc} --tag \"${key}: ${value}\""
  ) "" metric.tags;
in
pkgs.writeShellApplication {
  name = "git-metric-${name}";

  runtimeInputs = [
    gitMinimal
    git-metrics
  ];

  text = ''
    git metrics add ${name} ${tag_flags} "$(${pkgs.lib.getExe metric.script})"
  '';
}
