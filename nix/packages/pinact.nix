{ lib, fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "pinact";
  version = "3.9.0";

  src = fetchurl {
    url = "https://github.com/suzuki-shunsuke/pinact/releases/download/v${version}/pinact_darwin_arm64.tar.gz";
    hash = "sha256-I8ik7aj9eUnIy7HP5vPQEnlAL+YgHpywqQRHpez974k=";
  };

  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    install -Dm755 pinact $out/bin/pinact
  '';

  meta = {
    description = "Pin GitHub Actions versions";
    homepage = "https://github.com/suzuki-shunsuke/pinact";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
