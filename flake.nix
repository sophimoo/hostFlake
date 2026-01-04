{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hm-unstable.url = "github:nix-community/home-manager";
    hm-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    stylix.url = "github:nix-community/stylix/release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      hm-unstable,
      firefox-addons,
      ...
    }@inputs:
    let
      mkSystem = { hostname, system, pkgs-unstable ? false }:
        let
          pkgsInput = if pkgs-unstable then nixpkgs-unstable else nixpkgs;
          hmInput = if pkgs-unstable then hm-unstable else home-manager;

          pkgs = import pkgsInput {
            inherit system;
            config.allowUnfree = true;
          };

          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };

          homeManagerModules = with inputs; [
            nix-flatpak.homeManagerModules.nix-flatpak
            spicetify-nix.homeManagerModules.default
            plasma-manager.homeManagerModules.plasma-manager
            stylix.homeManagerModules.stylix
          ];
        in
        pkgsInput.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/${hostname}/configuration.nix
            hmInput.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs unstable; };
                users.sophie.imports = [ ./hosts/${hostname}/home.nix ] ++ homeManagerModules;
              };
            }
          ];

          specialArgs = { inherit inputs unstable; };
        };
    in
    {
      nixosConfigurations = {
        nix2015air = mkSystem {
          hostname = "nix2015air";
          system = "x86_64-linux";
        };

        nixHomeDesktop = mkSystem {
          hostname = "nixHomeDesktop";
          system = "x86_64-linux";
        };

        nixArmVM = mkSystem {
          hostname = "nixArmVM";
          system = "aarch64-linux";
        };
      };
    };
}
