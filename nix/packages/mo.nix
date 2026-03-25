{ lib, fetchurl, stdenv, unzip }:
stdenv.mkDerivation rec {
  pname = "mo";
  version = "0.21.0";

  src = fetchurl {
    url = "https://github.com/k1LoW/mo/releases/download/v${version}/mo_v${version}_darwin_arm64.zip";
    hash = "sha256-KWrE1HHwhViFK7mmHkaKdcfKNWzcfa1wW6vOUQdIRdM=";
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
