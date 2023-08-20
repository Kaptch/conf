# Testing
dd if=/dev/zero of=my-test.img bs=1M count=500 #Creates a 500 MB image file
sudo losetup /dev/loop0 my-test.img #Mounts on loop device loop0
sudo partprobe /dev/loop0 #creates block files for any partitions on the image

# Running
$ sudo disko -- --mode disko <disc config> --arg disks '[ "/dev/nvme0n1" ]'
