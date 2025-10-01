{
  pkgs,
  commonImports,
  git-metrics,
  gitMetricsLib,
  ...
}:

let
  # the git-metrics-flake is for running from within nix against some output derivation
  # So we need a "project" that we run git-metrics for. For that we use git-metrics itself ;-)
  projectDrv = git-metrics;

  git-metrics-binary-size = gitMetricsLib.metrics.binary_size { drv = projectDrv; };

  run-test = pkgs.writeShellApplication {
    name = "run-test";
    runtimeInputs = [
      pkgs.gitMinimal
      git-metrics

      git-metrics-binary-size
    ];

    text = ''
      cd repo
      echo "Calling git-metric-binary-size" | systemd-cat -p info
      git-metric-binary-size
      echo "Calling git-metric-binary-size finished" | systemd-cat -p info

      git-metrics show | grep -q binary-size
      echo "git-metric 'binary-size' present" | systemd-cat -p info
    '';
  };

  setup-repo = pkgs.writeShellApplication {
    name = "setup-repo";
    runtimeInputs = [
      pkgs.gitMinimal
      git-metrics
    ];
    text = ''
      echo "STARTING REPO SETUP" | systemd-cat -p info
      mkdir repo
      cd repo
      git init
      touch file
      git add file
      git commit file -m init

      git-metrics init
      echo "FINISHED REPO SETUP" | systemd-cat -p info
    '';
  };
in
pkgs.testers.runNixOSTest {
  name = "ci-script";
  nodes = {
    primary =
      {
        pkgs,
        ...
      }:
      {
        imports = commonImports;
        environment.systemPackages = [
          setup-repo
          run-test
        ];
      };
  };

  testScript = ''
    start_all()
    primary.succeed("setup-git")
    primary.succeed("setup-repo")
    primary.succeed("run-test")
  '';
}
