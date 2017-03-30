with import <nixpkgs> {};
let
  myRunLatex =
  { rootFile
  , generatePDF ? true # generate PDF, not DVI
  , generatePS ? false # generate PS in addition to DVI
  , extraFiles ? []
  , compressBlanksInIndex ? true
  , packages ? []
  , texPackages ? {}
  , copySources ? false
}:

assert generatePDF -> !generatePS;

let
  tex = pkgs.texlive.combine
  # always include basic stuff you need for LaTeX
  ({inherit (pkgs.texlive) scheme-basic;} // texPackages);
in

pkgs.stdenv.mkDerivation {
  name = "doc";

  builder = ./run-latex.sh;
  copyIncludes = ./copy-includes.pl;

  inherit rootFile generatePDF generatePS extraFiles
  compressBlanksInIndex copySources;

  includes = map (x: [x.key (baseNameOf (toString x.key))])
  (texFunctions.findLaTeXIncludes {inherit rootFile;});

  buildInputs = [ tex pkgs.perl ] ++ packages;
};
in
  myRunLatex {
    rootFile = src/paper.tex;
    texPackages = {
      inherit (pkgs.texlive)
      everypage
      scheme-full
      xkeyval
      background
      times
      courier
      wrapfig
      xcolor
      booktabs
      caption
      siunitx
      fixme
      todo
      tabulary
      algorithms
      algorithmicx
      acmart
      totpages
      environ
      trimspaces
      ncctools
      comment
      dirtree
      ;
    };
    extraFiles = [
      ./src
    ];
  }
