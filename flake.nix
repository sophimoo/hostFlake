{
  description = "A very basic flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    hm-unstable.url = "github:nix-community/home-manager";
    hm-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix/24.11";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    stylix.url = "github:nix-community/stylix/release-25.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, hm-unstable, ... }@inputs:
    let
      mkSystem = { hostname, system, unstable ? false, hmModules ? [] }:
        let
          pkgsInput = if unstable then nixpkgs-unstable else nixpkgs;
          hmInput = if unstable then hm-unstable else home-manager;
          
          pkgs = import pkgsInput {
            inherit system;
            config.allowUnfree = true;
          };
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
                extraSpecialArgs = { inherit inputs; };
                users.sophie.imports = 
                  [ ./hosts/${hostname}/home.nix ] ++ hmModules;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        nix2015air = mkSystem {
          hostname = "nix2015air";
          system = "x86_64-linux";
          hmModules = with inputs; [
            nix-flatpak.homeManagerModules.nix-flatpak
            spicetify-nix.homeManagerModules.default
            plasma-manager.homeManagerModules.plasma-manager
            stylix.homeManagerModules.stylix
          ];
        };

        nixHomeDesktop = mkSystem {
          hostname = "nixHomeDesktop";
          system = "x86_64-linux";
          hmModules = with inputs; [
            nix-flatpak.homeManagerModules.nix-flatpak
            spicetify-nix.homeManagerModules.default
            plasma-manager.homeManagerModules.plasma-manager
            stylix.homeManagerModules.stylix
          ];
        };

        nixArmVM = mkSystem {
          hostname = "nixArmVM";
          system = "aarch64-linux";
          unstable = true;
          hmModules = with inputs; [
            nix-flatpak.homeManagerModules.nix-flatpak
            spicetify-nix.homeManagerModules.default
            plasma-manager.homeManagerModules.plasma-manager
            stylix.homeManagerModules.stylix
          ];
        };
      };
    };
}