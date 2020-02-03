#!/bin/bash

ISO=debian-10.2.0-amd64-netinst.iso

OSTYPE=Debian_64

CURDIR=$(pwd)

echo "Downloading $ISO"

curl -C - -o "$CURDIR/$ISO" https://mirror.yandex.ru/debian-cd/10.2.0/amd64/iso-cd/$ISO

echo "|-------------------------------------------------------------------------------|"
echo "Checking VM's"

VBoxManage list vms

echo "|-------------------------------------------------------------------------------|"
echo "Creating $OSTYPE VM"

VBoxManage createvm --name $ISO.$OSTYPE --ostype $OSTYPE --register --basefolder "$CURDIR"

#echo "Info about created VM, $ISO.$OSTYPE"

#VBoxManage showvminfo $ISO.$OSTYPE

echo "|-------------------------------------------------------------------------------|"
echo "Configuring VM $ISO.$OSTYPE"
echo
echo "ram 512 vram 16, video vmsvga, audio off, recording off, boot order"

VBoxManage modifyvm $ISO.$OSTYPE --memory 512 --vram 16 --acpi on --ioapic on --graphicscontroller vmsvga --audio none --recording off --boot1 dvd --boot2 disk --boot3 none --boot4 none

echo "Add SATA, iocache on"

VBoxManage storagectl $ISO.$OSTYPE --name "SATA Controller" --add sata --controller IntelAhci --hostiocache on --bootable on --portcount 2

echo "Add IDE"

VBoxManage storagectl $ISO.$OSTYPE --name "IDE Controller" --add ide --controller PIIX4

echo "Creating Virtual Disk (vdi)"

VBoxManage createhd --filename "$CURDIR/$ISO.vdi" --size 1024 --variant Standard

echo "Add vdi and iso to the controllers"

VBoxManage storageattach $ISO.$OSTYPE --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$CURDIR/$ISO.vdi"

VBoxManage storageattach $ISO.$OSTYPE --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$CURDIR/$ISO"

echo "|-------------------------------------------------------------------------------|"
echo "SSH port forward "

VBoxManage modifyvm $ISO.$OSTYPE --natpf1 "ssh_portforw,tcp,127.0.0.1,4242,,22"

echo "|_/--------------------------------##DONE##-----------------------------------\_|"





#VBoxManage unregistervm debian-10.2.0-amd64-netinst.iso.Debian_64 --delete
#VBoxManage startvm debian-10.2.0-amd64-netinst.iso.Debian_64 --type headless

#Shrink image (vdi only)
#VBoxManage modifymedium debian-10.2.0-amd64-netinst.iso.vdi --compact

#echo "|-------------------------------------------------------------------------------|"

#-Superuser
#apt install sudo
#/usr/sbin/adduser user sudo

#-Add usefull tools
#sudo apt install htop mc tmux ipcalc tcpdump nmap zmap nmon secure-delete

#-In VM compress files, zeroing free space(for shrink image)
#sudo btrfs filesystem defragment -rvczstd /
#sudo btrfs filesystem usage /
#Balancing fs
#	manual	#sudo btrfs balance start -dusage=50 -musage=50 /
#sudo btrfs balance start --full-balance /
#sudo dd if=/dev/zero of=/mnt/zero.file bs=4K status=progress
#sudo rm -v /mnt/zero.file
