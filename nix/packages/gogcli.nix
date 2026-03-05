{ lib, fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "gogcli";
  version = "0.11.0";

  src = fetchurl {
    url = "https://github.com/steipete/gogcli/releases/download/v${version}/gogcli_${version}_darwin_arm64.tar.gz";
    hash = "sha256-ESaGjD+TmhSqlld9Vlj1/vHhU58zJzC/NaBudBYsnmE=";
  };

  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    install -Dm755 gog $out/bin/gog
  '';

  meta = {
    description = "Fast, script-friendly CLI for Gmail, Calendar, Drive, and other Google services";
    homepage = "https://github.com/steipete/gogcli";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
