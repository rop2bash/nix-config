{
  description = "NixOS system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    ags.url = "github:Aylur/ags";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = { url = "git+ssh://git@github.com/rop2bash/nix-secrets.git?shallow=1"; flake = false; };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
    overlays = [ (import inputs.rust-overlay) ];
    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in
  {

    nixosConfigurations.yuuki = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs system;
      };
      modules = [
        inputs.agenix.nixosModules.default
        ./nixos/configuration.nix
        ./secrets/default.nix
      ];
    };

    homeConfigurations.rop2bash = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home-manager/home.nix
      ];
    };

    devShells.${system}.default = with pkgs; mkShell {
      nativeBuildInputs = [
        libclang.lib
        llvmPackages.libcxxClang
        clang
      ];
      buildInputs = [
        protobuf
        openssl
        pkg-config
        eza
        fd
        rust-bin.stable.latest.default
      ];
      shellHook = ''
        export LIBCLANG_PATH=${pkgs.libclang.lib}/lib
        alias ls=eza
        alias find=fd
      '';
    };

  };
}
