{
  pkgs,
  callPackage,
  git-metrics,
  ...
}:

let
  setup-git = pkgs.writeShellApplication {
    name = "setup-git";
    runtimeInputs = [ pkgs.gitMinimal ];
    text = ''
      git config --global user.name Tester
      git config --global user.email "test@er.org"
    '';
  };

  commonDependenciesMod = (
    { pkgs, ... }:
    {
      environment.systemPackages = [
        setup-git
        pkgs.gitMinimal
        git-metrics
      ];
    }
  );

  commonImports = [
    commonDependenciesMod
  ];

in

{
  simple = callPackage ./simple.nix { inherit commonImports; };
  generate-metric-binary-size = callPackage ./generate-metric-binary-size.nix {
    inherit commonImports;
  };
}
