{
  description = "Declarative macOS environment with nix-darwin and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      llm-agents,
      ...
    }:
    let
      system = "aarch64-darwin";
      username = "yuki";
      configDir = ./config;
      llmAgentsPkgs = llm-agents.packages.${system};

      mkDarwinConfiguration =
        { profile }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit username profile configDir; };
          modules = [
            ./nix/modules/darwin

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit profile configDir llmAgentsPkgs; };
                users.${username} = import ./nix/modules/home;
              };
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        "home" = mkDarwinConfiguration { profile = "home"; };
        "work" = mkDarwinConfiguration { profile = "work"; };
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
