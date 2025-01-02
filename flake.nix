{
  description = "A very basic flake";

  inputs = {

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    hm-unstable.url = "github:nix-community/home-manager";
    hm-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      hm-unstable,
      nixpkgs,
      home-manager,
      nix-flatpak,
      spicetify-nix,
      plasma-manager,
      ...
    }@inputs:

    let
      system = builtins.trace system;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      lib-unstable = nixpkgs-unstable.lib;

      home-manager-modules = [
        nix-flatpak.homeManagerModules.nix-flatpak
        spicetify-nix.homeManagerModules.default
        plasma-manager.homeManagerModules.plasma-manager
      ];

      home-manager-config = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
        };
      };

    in
    {

      nixosConfigurations = {

        nix2015air = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nix2015air/configuration.nix
            # using home manager as a module
            home-manager.nixosModules.home-manager
            {
              home-manager = home-manager-config // {
                users.sophie.imports = [ ./hosts/nix2015air/home.nix ] ++ home-manager-modules;
              };

            }
          ];
        };

        nixHomeDesktop = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixHomeDesktop/configuration.nix
            # using home manager as a module
            home-manager.nixosModules.home-manager
            {
              home-manager = home-manager-config // {
                users.sophie.imports = [ ./hosts/nixHomeDesktop/home.nix ] ++ home-manager-modules;
              };

            }
          ];
        };

        nixArmVM = lib-unstable.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixArmVM/configuration.nix
            # using home manager as a module
            hm-unstable.nixosModules.home-manager
            {
              home-manager = home-manager-config // {
                users.sophie.imports = [ ./hosts/nixArmVM/home.nix ] ++ home-manager-modules;
              };

            }
          ];
        };

      };
    };

}
