  with import <nixpkgs> {};
texFunctions.runLaTeX {
  rootFile = ./paper.tex;
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
    ;
  };
  extraFiles = [
    figures/acmart.cls
    figures/acmst.bst
    figures/ANL-Intr.pdf
    figures/CEA-Curi.pdf
    figures/CTC-SP2.pdf
    figures/full-CEA-Curi.pdf
    figures/full-ANL-Intr.pdf
    figures/full-CTC-SP2.pdf
    figures/full-KTH-SP2.pdf
    figures/full-SDSC-BLU.pdf
    figures/full-SDSC-SP2.pdf
    figures/full-UniLu-Ga.pdf
    figures/KTH-SP2.pdf
    figures/mosaicbandit-UniLu-Ga.pdf
    figures/mosaic-UniLu-Ga.pdf
    figures/SDSC-BLU.pdf
    figures/SDSC-SP2.pdf
    figures/UniLu-Ga.pdf
    figures/variability.pdf
  ];
}
