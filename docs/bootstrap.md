parted /dev/sdX
mklabel gpt
mkpart ESP fat32 0% 512MiB
mkpart primary 512MiB 100%
set 1 esp on

pvcreate /dev/sdX2
vgcreate pool /dev/sdX2

lvcreate -L 15G -n root-private pool
lvcreate -L 15G -n root-work pool
lvcreate -l 100%FREE -n nix-store pool

cryptsetup luksFormat /dev/pool/root-work
cryptsetup luksFormat /dev/pool/root-private
cryptsetup luksFormat /dev/pool/nix-store
cryptsetup luksAddKey /dev/pool/nix-store

cryptsetup luksOpen /dev/pool/root-work crypto-work
cryptsetup luksOpen /dev/pool/root-private crypto-private
cryptsetup luksOpen /dev/pool/nix-store nix-store

mkfs.ext4 /dev/mapper/crypto-work
mkfs.ext4 /dev/mapper/crypto-private
mkfs.ext4 /dev/mapper/nix-store

mount /dev/mapper/crypto-work /mnt
mkdir -p /mnt/etc/nixos /mnt/boot /mnt/nix
mount /dev/mapper/nix-store /mnt/nix
mkdir /mnt/nix/config
mount --bind /mnt/nix/config /mnt/etc/nixos
mount /dev/sda1 /mnt/boot

nixos-generate-config --root /mnt

fileSystems."/" =
  { device = "/dev/mapper/crypto-work";
    fsType = "ext4";
  };

boot.initrd.luks.devices."crypto-work".device = "/dev/pool/root-work";

boot.initrd.availableKernelModules = ["ata_generic" "uhci_hcd" "ehci_pci" "ahci" "usb_storage" "sd_mod"];
boot.initrd.kernelModules = ["dm-snapshot"];
boot.kernelModules = ["kvm-intel"];
boot.extraModulePackages = [];

fileSystems."/" = {
  device = "/dev/mapper/crypto-work";
  fsType = "ext4";
};
