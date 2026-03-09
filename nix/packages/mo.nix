{ lib, fetchurl, stdenv, unzip }:
stdenv.mkDerivation rec {
  pname = "mo";
  version = "0.16.1";

  src = fetchurl {
    url = "https://github.com/k1LoW/mo/releases/download/v${version}/mo_v${version}_darwin_arm64.zip";
    hash = "sha256-ML/daLblD12eNoJW06dQvM9oyfEwNgGnI+HxlpVlPF0=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ unzip ];
  dontBuild = true;

  installPhase = ''
    install -Dm755 mo $out/bin/mo
  '';

  meta = {
    description = "Markdown viewer that opens .md files in a browser";
    homepage = "https://github.com/k1LoW/mo";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
