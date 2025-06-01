{
  pkgs,
  commonImports,
  git-metrics,
  ...
}:

let
  test = pkgs.writeShellApplication {
    name = "run-test";
    runtimeInputs = [
      pkgs.gitMinimal
      git-metrics
    ];
    text = ''
      echo "STARTING TEST" | systemd-cat -p info
      mkdir repo
      cd repo
      git init
      touch file
      git add file
      git commit file -m init

      git-metrics init

      # This is just a smoke-test, so lets do something irrelevant
      git-metrics add binary-size --tag "platform.os: linux" 0.0

      # And test whether it is there
      git-metrics show | grep -q binary-size

      echo "FINISHED TEST" | systemd-cat -p info
    '';
  };
in
pkgs.testers.runNixOSTest {
  name = "simple";
  nodes = {
    primary =
      {
        pkgs,
        ...
      }:
      {
        imports = commonImports;
        environment.systemPackages = [ test ];
      };
  };

  testScript = ''
    start_all()
    primary.succeed("setup-git")
    primary.succeed("run-test")
  '';
}
