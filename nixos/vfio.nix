
{config, pkgs, lib, ... }:

with lib;
let
  cfg = config.vfio;
in {
  options.vfio = {
    enable = mkEnableOption "PCI Passthrough";

    cpuType = mkOption {
      description = "'intel' or 'amd'";
      default = "amd";
      type = types.str;
    };

    pciIDs = mkOption {
      description = "Comma-separated list of PCI IDs to pass-through";
      type = types.str;
    };

    libvirtUsers = mkOption {
      description = "Extra users to add to libvirtd";
      type = types.listOf types.str;
      default = [];
    };
  };

  config = (mkIf cfg.enable {
  	boot.kernelParams = [ "${cfg.cpuType}_iommu=on" ];
  	  
  	# These modules are required for PCI passthrough, and must come before early modesetting stuff
  	boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
  	
  	# CHANGE: Don't forget to put your own PCI IDs here
  	boot.extraModprobeConfig ="options vfio-pci ids=${cfg.pciIDs}";

	hardware.graphics.enable = true;
	#virtualization.spiceUSBRedireciton.enable = true;
  	
  	environment.systemPackages = with pkgs; [
  	  virt-manager
  	  qemu
  	  OVMFFull
	  looking-glass-client
	  swtpm
  	];

	systemd.tmpfiles.rules = [
	  "f /dev/shm/looking-glass 0660 rop2bash kvm - "
	];
	systemd.user.services.scream = {
		enable = true;
		description = "Scream Audio Server";
		serviceConfig = {
			ExecStart = "${pkgs.scream}/bin/scream -i virbr0 -n win11";
			Restart = "always";
		};
		wantedBy = [ "default.target" ];
		requires = [ "pipewire-pulse.service" ];
	};
		
  	
  	virtualisation.libvirtd.enable = true;
  	
  	# CHANGE: add your own user here
  	users.groups.libvirtd.members = [ "root" ] ++ cfg.libvirtUsers;
  	
	virtualisation.libvirtd.qemu = {
  		package = pkgs.qemu_kvm;
		#verbatimConfig = ''
    		#  nvram = [
    		#  "${pkgs.OVMF}/FV/OVMF.fd:${pkgs.OVMF}/FV/OVMF_VARS.fd"
    		#  ]
    		#'';
		swtpm.enable = true;
		ovmf = {
			enable = true;
			packages = [pkgs.OVMFFull.fd ];
		};
	};
  });

}
