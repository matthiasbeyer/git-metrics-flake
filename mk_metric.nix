{
  pkgs,
  git-metrics,
  gitMinimal,
  ...
}:

{
  name,
  script,
  tags ? { },
  ...
}:

let
  tag_flags = pkgs.lib.attrsets.foldlAttrs (
    acc: key: value:
    "${acc} --tag \"${key}: ${value}\""
  ) "" tags;
in
pkgs.writeShellApplication {
  name = "git-metric-${name}";

  runtimeInputs = [
    gitMinimal
    git-metrics
  ];

  text = ''
    git metrics add ${name} ${tag_flags} "$(${pkgs.lib.getExe script})"
  '';
}
