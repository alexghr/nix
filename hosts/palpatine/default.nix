{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.palpatine =
    withSystem
    "x86_64-linux"
    (
      {system, ...}:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            alexghrKeys = (import ../../alexghr.keys.nix).ssh;
            nixosModules = self.nixosModules;
          };

          modules = [
            ./configuration.nix
            ({
              pkgs,
              lib,
              ...
            }: let
              # The latest libfido2 build fails to receive resident keys
              opensshFido = pkgs.openssh.override {
                libfido2 = (import inputs.nixpkgs-fido {inherit system;}).libfido2;
              };
            in {
              programs.ssh.package = opensshFido;
              home-manager.users.ag.services.ssh-agent.package = lib.mkForce opensshFido;
            })
          ];
        }
    );
}
