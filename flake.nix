{
  description = "A very basic flake";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.

  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }@inputs:
    
    let
      system = "x86_64-linux";  
      pkgs = import nixpkgs {
        inherit system;
	config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    
    in 
    {

      nixosConfigurations = {

        nix2015air = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nix2015air/configuration.nix
            # using home manager as a module
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.sophie = {
                    imports = [ 
                      ./hosts/nix2015air/home.nix
                      nix-flatpak.homeManagerModules.nix-flatpak
                    ];
                  };
            }
          ];
        };

        nixHomeDesktop = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixHomeDesktop/configuration.nix
            # using home manager as a module
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.sophie = {
                    imports = [
                      ./hosts/nixHomeDesktop/home.nix
                      nix-flatpak.homeManagerModules.nix-flatpak
                    ];
                  };
            }
          ];
        };

      };
    };

}
