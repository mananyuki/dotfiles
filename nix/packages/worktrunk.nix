{ lib, fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "worktrunk";
  version = "0.31.0";

  src = fetchurl {
    url = "https://github.com/max-sixty/worktrunk/releases/download/v${version}/worktrunk-aarch64-apple-darwin.tar.xz";
    hash = "sha256-u5rb9ZPfbhRaFeFIF15VJNxEFuAqrEq3pQFUxOcMuaU=";
  };

  sourceRoot = "worktrunk-aarch64-apple-darwin";
  dontBuild = true;

  installPhase = ''
    install -Dm755 wt $out/bin/wt
    install -Dm755 git-wt $out/bin/git-wt
  '';

  meta = {
    description = "A CLI tool for managing git worktrees";
    homepage = "https://github.com/max-sixty/worktrunk";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
  };
}
