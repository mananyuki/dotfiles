{ lib, fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "datadog-mcp-cli";
  version = "0-unstable";

  src = fetchurl {
    url = "https://coterm.datadoghq.com/mcp-cli/datadog_mcp_cli-macos-arm64";
    hash = "sha256-LspK1fIHtNfs3HJM1T6qNhm53h732MW/WdAlSlqMRB8=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 $src $out/bin/datadog_mcp_cli
  '';

  meta = {
    description = "Datadog MCP server CLI";
    homepage = "https://docs.datadoghq.com/bits_ai/mcp_server/";
    platforms = [ "aarch64-darwin" ];
  };
}
