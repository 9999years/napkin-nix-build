{ pkgs ? import <nixpkgs> { }, }:
with pkgs;
stdenv.mkDerivation rec {
  name = "napkin";
  version = "1.5.20190129";

  src = fetchFromGitHub {
    owner = "vEnhance";
    repo = "napkin";
    rev = "9b7780953eb87b1147f0d125d3dc9f8168f022e7";
    sha512 = "1bl5laj4jb835fpfjj3i1vw9p706f5a54ab5pr1ldakdd43jmn9zj6nrcrdjdnf8v58606s6w5hplisi3jzq1jcqxcwq1n1cxs4qrf4";
  };

  buildInputs = [
    wget
    freeglut
    ghostscript
    tree
    asymptote
    (texlive.combine rec {
      inherit (texlive)
        scheme-small collection-latexrecommended collection-latexextra
        collection-mathscience collection-bibtexextra asymptote latexmk biber;
    })
  ];

  buildPhase = ''
    mkdir asy/
    pdflatex -interaction=batchmode Napkin.tex
    HOME="$PWD" asy -o asy/ asy/Napkin-*.asy -v
    biber Napkin
    pdflatex -interaction=batchmode Napkin.tex
    pdflatex -interaction=batchmode Napkin.tex
    pdflatex -interaction=batchmode Napkin.tex
    pdflatex -interaction=batchmode Napkin.tex
  '';

  installPhase = ''
    mkdir -p $out
    mv Napkin.pdf $out/
    mv Napkin.log $out/
    mkdir -p $out/asy/
    mv asy/*.pdf $out/asy/
    cd $out/
    tree -H . \
         -I "index.html" \
         -D \
         --charset utf-8 \
         -T "An Infinitely Large Napkin" \
         > index.html
  '';
}
