{pkgs ? import <nixpkgs> {} }:
let
  tb = pkgs.fetchurl {
    url= "https://github.com/NixOS/nixpkgs/archive/38b2e27.tar.gz";
    sha256= "1pgvmnf3zbcz6wa0l9synaav413nf7aazz2qkz14l58nkiwjh55f";
  };
in with import tb {};
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
        pkgs.bc
      ];
      configurePhase = ''rm -rf o; echo ${src}'';
      buildPhase = "zymake -l localhost zymakefile";
      installPhase = ''echo "e"'';
    };
  };
in
  self
