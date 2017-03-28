{pkgs ? import <nixpkgs> {} }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // pkgs.xlibs // self);
  self = rec {
    obandit = pkgs.ocamlPackages.callPackage pkgs/obandit { };
    zymake = pkgs.ocamlPackages.callPackage pkgs/zymake { };
    ocs = pkgs.ocamlPackages.callPackage pkgs/ocs { inherit obandit; };
    banditSelection=pkgs.stdenv.mkDerivation rec {
      name = "banditSelection";
      src = ./.;
      buildInputs =
      [
        obandit
        zymake
        ocs
        pkgs.pythonPackages.docopt
        pkgs.R
        pkgs.rPackages.docopt
        pkgs.rPackages.ggplot2
        pkgs.rPackages.dplyr
        pkgs.rPackages.lubridate
        pkgs.rPackages.directlabels
        pkgs.rPackages.ggmosaic
        pkgs.bc
      ];
      configurePhase = ''rm -rf o; echo ${src}'';
      buildPhase = "zymake -l localhost zymakefile";
      installPhase = ''cp o/zymakefile/*.pdf /share"'';
    };
  };
in
  self
