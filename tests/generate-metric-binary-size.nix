{
  pkgs,
  commonImports,
  git-metrics,
  gitMetricsLib,
  ...
}:

let
  git-metrics-binary-size = gitMetricsLib.mkMetric {
    name = "binary-size";
    script = pkgs.writeShellApplication {
      name = "get-binary-size";
      runtimeInputs = [
        pkgs.gnused
        pkgs.coreutils
      ];
      text = ''
        du --bytes --dereference-args ${pkgs.lib.getExe git-metrics} | sed -E 's/([0-9]+).*/\1/'
      '';
    };

    tags = {
      "testkey" = "testvalue";
    };
  };

  run-test = pkgs.writeShellApplication {
    name = "run-test";
    runtimeInputs = [
      pkgs.gitMinimal
      git-metrics
    ];

    text = ''
      cd repo
      echo "Calling git-metric-binary-size" | systemd-cat -p info
      ${pkgs.lib.getExe git-metrics-binary-size}
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
