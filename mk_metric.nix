{ pkgs, git-metrics, ... }:

{
  metricName,
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
  name = "git-metric-${metricName}";

  text = ''
    ${pkgs.lib.getExe git-metrics} \
      add ${metricName} \
      ${tag_flags} \
      $(${generator})
  '';
}
