{
  description = "Declarative macOS environment with nix-darwin and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      username = "yuki";

      mkDarwinConfiguration =
        { hostname, profile }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit username profile; };
          modules = [
            ./nix/modules/darwin

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit profile; };
                users.${username} = import ./nix/modules/home;
              };
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        "JPN-2024-059-home" = mkDarwinConfiguration {
          hostname = "JPN-2024-059";
          profile = "home";
        };
        "JPN-2024-059-work" = mkDarwinConfiguration {
          hostname = "JPN-2024-059";
          profile = "work";
        };
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
