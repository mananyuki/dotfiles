{ lib, fetchurl, stdenv, unzip }:
stdenv.mkDerivation rec {
  pname = "deck";
  version = "1.23.0";

  src = fetchurl {
    url = "https://github.com/k1LoW/deck/releases/download/v${version}/deck_v${version}_darwin_arm64.zip";
    hash = "sha256-UcKJ4lwdyNi+h6bMbyEJhsdizI/x1cQU6mE1bTreF6I=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ unzip ];
  dontBuild = true;

  installPhase = ''
    install -Dm755 deck $out/bin/deck
  '';

  meta = {
    description = "Build and manage custom and standard slide decks";
    homepage = "https://github.com/k1LoW/deck";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
