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
    figures/ctc_sp.pdf
    figures/kth_sp.pdf
    figures/sdsc_b.pdf
    figures/sdsc_s.pdf
    figures/cea_cu.pdf
    figures/unilug.pdf
    figures/anl_in.pdf
    figures/mosaic_noisy.pdf
    figures/mosaic_bandit.pdf
    figures/all.pdf
    figures/acmart.cls
    figures/acmst.bst
  ];
}
