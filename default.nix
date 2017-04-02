{pkgs ? import <nixpkgs> {} }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // pkgs.xlibs // self);
  self = rec {
    zymake = pkgs.ocamlPackages.callPackage pkgs/zymake { };
    ocs = pkgs.ocamlPackages.callPackage pkgs/ocs { };
    banditSelection=pkgs.stdenv.mkDerivation rec {
      name = "banditSelection";
      src = ./.;
      buildInputs =
      [
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
      #configurePhase = ''rm -rf o'';
      buildPhase = "zymake -l localhost zymakefile";
      installPhase = ''
        mkdir -p $out/pdfs/
        mv o/zymakefile/*.pdf $out/pdfs
        '';
    };
  };
in
  self
