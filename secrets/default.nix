{ config, pkgs, inputs, ... }:

{
  age.identityPaths = [
    "/home/rop2bash/.ssh/id_ed25519"
  ];
  
  age.secrets."vpn-conf" = {
    file = "${inputs.secrets}/wg-yuuki.age";
  };
}
