{ pkgs, drv, ... }:

pkgs.writeShellApplication {
  name = "binary_size";

  text =
    let
      du = "${pkgs.coreutils}/bin/du";
      sed = pkgs.lib.getExe pkgs.sed;
    in
    ''
      ${du} --dereference-args ${drv} | ${sed} -E 's/([0-9]+).*/\1/'
    '';
}
