#! /bin/bash
set -e # Stop script on error

# boot partition size, in MB
BOOTPARTSIZE=512

# root partition size, in GB
ROOTPARTSIZE=32

# hostname
HOSTNAME=MCRN-Donnager

# user
USERNAME=wilson

# locale
CONTINENT=AMERICA
CITY=Detroit

echo "

		      Welcome to...

      ___           ___           ___           ___     
     /\  \         /\__\         /\  \         /\  \    
    /::\  \       /:/  /         \:\  \       /::\  \   
   /:/\:\  \     /:/  /           \:\  \     /:/\:\  \  
  /::\~\:\  \   /:/  /  ___       /::\  \   /:/  \:\  \ 
 /:/\:\ \:\__\ /:/__/  /\__\     /:/\:\__\ /:/__/ \:\__\\
 \/__\:\/:/  / \:\  \ /:/  /    /:/  \/__/ \:\  \ /:/  /
      \::/  /   \:\  /:/  /    /:/  /       \:\  /:/  / 
      /:/  /     \:\/:/  /     \/__/         \:\/:/  /  
     /:/  /       \::/  /                     \::/  /   
     \/__/         \/__/                       \/__/    
      ___           ___           ___           ___     
     /\  \         /\  \         /\  \         /\__\    
    /::\  \       /::\  \       /::\  \       /:/  /    
   /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/__/     
  /::\~\:\  \   /::\~\:\  \   /:/  \:\  \   /::\  \ ___ 
 /:/\:\ \:\__\ /:/\:\ \:\__\ /:/__/ \:\__\ /:/\:\  /\__\\
 \/__\:\/:/  / \/_|::\/:/  / \:\  \  \/__/ \/__\:\/:/  /
      \::/  /     |:|::/  /   \:\  \            \::/  / 
      /:/  /      |:|\/__/     \:\  \           /:/  /  
     /:/  /       |:|  |        \:\__\         /:/  /   
     \/__/         \|__|         \/__/         \/__/    

     			
     	        Press any key to continue.
"

# Don't start until user is ready
read ; echo

# Set up time
timedatectl set-ntp true

# show drives available
echo "Here are the drives that are seen by your system." ; echo
lsblk

# Set drive for installation
echo ; echo
echo "Which drive (from the above list) do you wish to install to? " ; echo ; echo
echo "The path to your installation drive should have a format like this -> '/dev/sda'"
read -p "Enter the path to that drive that you wish to install to: " TGTDEV

# # Alternatively to the auto format solution below you could cfdisk manually
#  cfdisk ${TGTDEV}

# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
#The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
 g # clear the in memory partition table, and make a new gpt one
 n # new partition
 1 # partition number 1
   # default - start at beginning of disk 
 +${BOOTPARTSIZE}M # 512MiB boot parttion
 t # type of partition
 1 # partition type 1 'efi'
 n # new partition
 2 # partition number 2
  # default, start immediately after preceding partition
 +${ROOTPARTSIZE}G # 32Gib root partition
t # type of partition
 2 # partition number 2
 24 # partition type 24 'Linux root (x86-64)'
 n # new partition
 3 # partition number 3
   # default, start immediately after preceding partition
   # default, Go to the end of the disk
 t # type of partition
 3 # partition number 3
 28 # partition type 28 'Linux Home'
 p # print the in-memory partition table
 w # write the partition table
EOF

# Format the partitions
mkfs.fat -F32 ${TGTDEV}1
mkfs.ext4 ${TGTDEV}2
mkfs.ext4 ${TGTDEV}3

## Initate pacman keyring
#pacman-key --init
#pacman-key --populate archlinux
#pacman-key --refresh-keys

# Mount the partitions
#mkdir /mnt/boot
#mkdir /mnt/boot/efi
#mount ${TGTDEV}1 /mnt/boot/efi
mount ${TGTDEV}2 /mnt
mkdir /mnt/home
mount ${TGTDEV}3 /mnt/home

# Setup the cpu microcode package
#read -p "Are you installing on a computer with an AMD[1] or Intel[2] cpu: " CPU

# Install reflector for sorting mirrors
pacman -Sy reflector --noconfirm

# Store a backup of the mirrors that came with the installation
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Get the fastest in-sync (up-to-date) mirrors and store 10 of them (sorted) in mirrorlist
reflector -l 200 -f 10 --sort score > /etc/pacman.d/mirrorlist

# # Minimal install with pacstrap (graphical setup will be done in another script)
# pacstrap /mnt base base-devel linux linux-firmware intel-ucode efibootmgr grub \
# nano neovim git openssh networkmanager device-mapper mesa wget curl man-db man-pages \
# diffutils zsh exa dosfstools neofetch sl figlet cowsay ranger htop pulseaudio tigervnc \
# wpa_supplicant dialog os-prober xorg xorg-xinit xorg-xrandr openbox gnome-terminal \
# firefox thunar nitrogen tint2 lxappearance
pacstrap /mnt base base-devel linux linux-firmware nano vim zsh

# Generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

##############################################################################
# The folowing code block is exactly what i did to install based off of a guid on tecmint
##############################################################################
arch-chroot /mnt <<EOF
echo ${HOSTNAME} > /etc/hostname
sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i -e 's/#en_US ISO-8859-1/en_US ISO-8859-1/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
export LANG=en_US.UTF-8
echo "127.0.0.1 localhost" >> /mnt/etc/hosts
echo "::1 localhost" >> /mnt/etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >> /mnt/etc/hosts
ln -s /usr/share/zoneinfo/${CONTINENT}/${CITY} /etc/localtime # check into this may not be right
hwclock --systohc
pacman -Syu --noconfirm

echo "Enter password for root: " && read ROOTPASS && echo -e "${ROOTPASS}\n${ROOTPASS}" | passwd

useradd -mg users -G wheel,storage,power -s /bin/zsh ${USERNAME}
echo "Enter password for ${USERNAME}: " && read USERPASS && echo -e "${USERPASS}\n${USERPASS}" | passwd ${USERNAME}

chage -d 0 wilson
sed -i -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

pacman -S grub efibootmgr dosfstools os-prober mtools --noconfirm
mkdir /boot/EFI
mount ${TGTDEV}1 /boot/EFI

genfstab -U -p / >> /etc/fstab

grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
EOF
umount -a
telinit 6

##############################################################################

# # chroot into system
# arch-chroot /mnt /bin/bash <<EOF

# # Setting system clock
# read -p "Enter the continent where you live: " CONTINENT
# read -p "Enter the city where you live: " CITY
# ln -sf /usr/share/zoneinfo/${CONTINENT}/${CITY} /etc/localtime

# # Setting hardware clock
# hwclock --systohc --localtime

# # Setting locales
# echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
# echo "LANG=en_US.UTF-8" >> /etc/locale.conf
# locale-gen

# # Adding persistent keymap (Will probably never need this as the US layout is default)
# # echo "KEYMAP=us" > /etc/vconsole.conf

# # Set hostname
# read -p "Enter a hostname for the computer: " HOSTNAME
# echo $HOSTNAME > /etc/hostname

# # Set-up hosts file
# echo "127.0.0.1 localhost" >> /etc/hosts
# echo "::1 localhost" >> /etc/hosts
# echo "127.0.1.1 ${HOSTNAME}.localdomain  ${HOSTNAME}" >> /etc/hosts

# # Set root password
# echo "Username: root"
# passwd


# # Create new sudo user
# read -p "Enter username: " USERNAME
# useradd -m -G wheel -s /bin/zsh ${USERNAME}
# usermod -a -G video ${USERNAME}
# passwd ${USERNAME}
# echo '%wheel ALL=(ALL) ALL' | EDITOR='tee -a' visudo

# # add 'Defaults !tty_tickets' to not have to retype in your sudo password all of the times
# # also add Luke Smith thing so I can reboot without sudo

# # # Generate initramfs
# # sed -i 's/^HOOKS.*/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)/' /etc/mkinitcpio.conf
# # sed -i 's/^MODULES.*/MODULES=(ext4 intel_agp i915)/' /etc/mkinitcpio.conf
# # mkinitcpio -p linux
# # mkinitcpio -p linux-lts
# # echo "Setting up systemd-boot"
# # bootctl --path=/boot install
# # mkdir -p /boot/loader/
# # touch /boot/loader/loader.conf
# # tee -a /boot/loader/loader.conf << END
# # default arch
# # timeout 1
# # editor 0
# # END
# # mkdir -p /boot/loader/entries/
# # touch /boot/loader/entries/arch.conf
# # tee -a /boot/loader/entries/arch.conf << END
# # title ArchLinux
# # linux /vmlinuz-linux
# # initrd /intel-ucode.img
# # initrd /initramfs-linux.img
# # options rd.luks.name=$(blkid -s UUID -o value /dev/nvme0n1p2)=cryptlvm root=/dev/vg0/root resume=/dev/vg0/swap rd.luks.options=discard i915.fastboot=1 quiet rw
# # END
# # touch /boot/loader/entries/archlts.conf
# # tee -a /boot/loader/entries/archlts.conf << END
# # title ArchLinux
# # linux /vmlinuz-linux-lts
# # initrd /intel-ucode.img
# # initrd /initramfs-linux-lts.img
# # options rd.luks.name=$(blkid -s UUID -o value /dev/nvme0n1p2)=cryptlvm root=/dev/vg0/root resume=/dev/vg0/swap rd.luks.options=discard i915.fastboot=1 quiet rw
# # END
# # echo "Setting up Pacman hook for automatic systemd-boot updates"
# # mkdir -p /etc/pacman.d/hooks/
# # touch /etc/pacman.d/hooks/systemd-boot.hook
# # tee -a /etc/pacman.d/hooks/systemd-boot.hook << END
# # [Trigger]
# # Type = Package
# # Operation = Upgrade
# # Target = systemd
# # [Action]
# # Description = Updating systemd-boot
# # When = PostTransaction
# # Exec = /usr/bin/bootctl update
# # 

# # Setup bootloader
# # read -p "Would you like to install grub[1] or systemd-boot[1]: " BOOTLOADER

# # Install grub as bootloader
# pacman -S grub --noconfirm
# mkdir /boot/grub/
# grub-mkconfig -o /boot/grub/grub.cfg
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck

# # Enable periodic TRIM
# systemctl enable fstrim.timer

# # Enable NetworkManager
# systemctl enable NetworkManager

# # Enable openssh
# systemctl enable sshd.service

# EOF

# umount -R /mnt

# echo "ArchLinux is ready. You can reboot now!"
