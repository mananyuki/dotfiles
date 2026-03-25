{ lib, fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "pup";
  version = "0.36.0";

  src = fetchurl {
    url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
    hash = "sha256-QueONIiVV6HqoaP6qC7y/g4WCscdJcUs8SjclAbP+2Y=";
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
