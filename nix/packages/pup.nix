{ lib, fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "pup";
  version = "0.26.0";

  src = fetchurl {
    url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
    hash = "sha256-pv3oYngZgg4V4hf2zO1xB7meACKAdNrM0AXxLW4W9Qc=";
  };

  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    install -Dm755 pup $out/bin/pup
  '';

  meta = {
    description = "Datadog Pipelines Utility Pack";
    homepage = "https://github.com/datadog-labs/pup";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
  };
}
