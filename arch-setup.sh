#!/bin/bash

# https://github.com/prmsrswt/arch-install.sh

function ascii {

	#Added ASCII Art cause why not
	echo	' $$$$$$\                      $$\             $$$$$$\                       $$\               $$\ $$\ '
	echo	'$$  __$$\                     $$ |            \_$$  _|                      $$ |              $$ |$$ |'
	echo	'$$ /  $$ | $$$$$$\   $$$$$$$\ $$$$$$$\          $$ |  $$$$$$$\   $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ |'
	echo	'$$$$$$$$ |$$  __$$\ $$  _____|$$  __$$\         $$ |  $$  __$$\ $$  _____|\_$$  _|   \____$$\ $$ |$$ |'
	echo	'$$  __$$ |$$ |  \__|$$ /      $$ |  $$ |        $$ |  $$ |  $$ |\$$$$$$\    $$ |     $$$$$$$ |$$ |$$ |'
	echo	'$$ |  $$ |$$ |      $$ |      $$ |  $$ |        $$ |  $$ |  $$ | \____$$\   $$ |$$\ $$  __$$ |$$ |$$ |'
	echo	'$$ |  $$ |$$ |      \$$$$$$$\ $$ |  $$ |      $$$$$$\ $$ |  $$ |$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |'
	echo	'\__|  \__|\__|       \_______|\__|  \__|      \______|\__|  \__|\_______/    \____/  \_______|\__|\__|'
	echo	'                                                                                                      '
	echo	'                                                                                                      '

}


function br {
	# Just output a bunch of crap, but it looks cool so..
	for ((i=1; i<=`tput cols`; i++)); do echo -n -; done
}

function cont {
	read -r -p "[SUCCESS] Continue to next step? [Y/n] " contin
	case $continue in
		[Nn][oO]|[nN] )
			exit
			;;
		*)
			;;
	esac
}

function set-time {
	echo "Setting time...."
	# This command fixes different time reporting when dual booting with windows.
	timedatectl set-local-rtc 1 --adjust-system-clock
}

function partition {
	br
	read -r -p "Do you want to do partioning? [y/N] " resp
	case "$resp" in
		[yY][eE][sS]|[yY])
			echo "gdisk will be used for partioning"
			read -r -p "which drive you want to partition (exapmle /dev/sda)? " drive
			# Using gdisk for GPT, if you want to use MBR replace it with fdisk
			cfdisk $drive
			;;
		*)
			;;
	esac
	cont
}

function mounting {
	br
	read -r -p "which is your root partition? " rootp
	mkfs.btrfs -f $rootp
	mount $rootp /mnt
    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@var
    btrfs su cr /mnt/@opt
    btrfs su cr /mnt/@tmp
    umount /mnt
    mount -o noatime,commit=120,compress=zstd,subvol=@ $rootp /mnt
	mkdir /mnt/{home,boot,var,opt,tmp}
	read -r -p "which is your boot partition? " bootp
	read -r -p "Do you want to format your boot partition? [y/N] " response
	case "$response" in
		[yY][eE][sS]|[yY])
			mkfs.fat -F32 $bootp
			;;
		*)
			;;
	esac
	mount $bootp /mnt/boot
    mount -o noatime,commit=120,compress=zstd,subvol=@opt $rootp /mnt/opt
    mount -o noatime,commit=120,compress=zstd,subvol=@tmp $rootp /mnt/tmp
	mount -o noatime,commit=120,compress=zstd,subvol=@home $rootp /mnt/home
	mount -o subvol=@var $rootp /mnt/var
	cont
}

function base {
	br
	echo "Starting installation of packages in selected root drive..."
	sleep 1
	pacman -Sy
	pacstrap /mnt \
				base \
				diffutils \
				e2fsprogs \
				inetutils \
				less \
				linux \
				linux-firmware \
				logrotate \
				man-db \
				man-pages \
				nano \
				texinfo \
				usbutils \
				which \
				base-devel \
				networkmanager \
				sudo \
				bash-completion \
				git \
				vim \
				exfat-utils \
				ntfs-3g \
				grub \
				os-prober \
				efibootmgr \
				htop \
				vlc \
				pacman-contrib \
				ttf-hack \
                intel-ucode \
                btrfs-progs \
				reflector
	genfstab -U /mnt >> /mnt/etc/fstab
	cont
}

function set-timezone {
    echo "Set your timezone "
    read -r -p "What country do you live in? (Capitalize first letter):" country
    read -r -p "What city do you live in? (Capitalize first letter):" city
    arch-chroot /mnt bash -c "ln -sf /usr/share/zoneinfo/$country/$city /etc/localtime && exit"
    cont
}


function install-gnome {
	pacstrap /mnt gnome gnome-tweaks papirus-icon-theme
	arch-chroot /mnt bash -c "systemctl enable gdm && exit"
	# Editing gdm's config for disabling Wayland as it does not play nicely with Nvidia
	arch-chroot /mnt bash -c "sed -i 's/#W/W/' /etc/gdm/custom.conf && exit"
}

function install-deepin {
	pacstrap /mnt deepin lightdm gedit
	arch-chroot /mnt bash -c "systemctl enable lightdm && exit"
}

function install-kde {
	pacstrap /mnt xorg plasma kde-applications sddm plasma-wayland-protocols plasma-wayland-session
	arch-chroot /mnt bash -c "systemctl enable sddm && exit"
	pacstrap /mnt ark dolphin ffmpegthumbs gwenview kaccounts-integration kate kdialog kio-extras konsole ksystemlog okular print-manager pipewire alacritty latte-dock
}

function de {
	br
	echo -e "Choose a Desktop Environment to install: \n"
	echo -e "1. GNOME \n2. Deepin \n3. KDE \n4. None"
	read -r -p "DE: " desktope
	case "$desktope" in
		1)
			install-gnome
			;;
		2)
			install-deepin
			;;
		3)
			install-kde
			;;
		*)
			;;
	esac
	cont
}

function installgrub {
	read -r -p "Install GRUB bootloader? [y/N] " igrub
	case "$igrub" in
		[yY][eE][sS]|[yY])
			echo -e "Installing GRUB.."
			arch-chroot /mnt bash -c "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --removable && grub-mkconfig -o /boot/grub/grub.cfg && exit"
			;;
		*)
			;;
	esac
	cont
}

function archroot {
	br
	read -r -p "Enter the username: " uname
	read -r -p "Enter the hostname: " hname

	echo -e "Setting up Language\n"
	arch-chroot /mnt bash -c "hwclock --systohc && sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen && echo 'LANG=en_US.UTF-8' > /etc/locale.conf && exit"

	echo -e "Setting up Hostname\n"
	arch-chroot /mnt bash -c "echo $hname > /etc/hostname && echo 127.0.0.1	$hname > /etc/hosts && echo ::1	$hname >> /etc/hosts && echo 127.0.1.1	$hname.localdomain	$hname >> /etc/hosts && exit"

	echo "Set Root password"
	arch-chroot /mnt bash -c "passwd && useradd -mG wheel $uname && echo 'set user password' && passwd $uname && EDITOR=nano visudo && exit"

    echo "add btrfs module to mkinitcpio"
    arch-chroot /mnt bash -c "nano /etc/mkinitcpio.conf && mkinitpio -P && exit"

	echo -e "enabling services...\n"
	arch-chroot /mnt bash -c "systemctl enable bluetooth && exit"
	arch-chroot /mnt bash -c "systemctl enable NetworkManager && exit"
	
	echo -e "enabling paccache timer...\n"
	arch-chroot /mnt bash -c "systemctl enable paccache.timer && exit"

	echo -e "Editing configuration files...\n"
	# Enabling multilib in pacman
	arch-chroot /mnt bash -c "sed -i '93s/#\[/\[/' /etc/pacman.conf && sed -i '94s/#I/I/' /etc/pacman.conf && pacman -Syu && sleep 1 && exit"
	# Tweaking pacman, uncomment options Color, TotalDownload and VerbosePkgList
	arch-chroot /mnt bash -c "sed -i '34s/#C/C/' /etc/pacman.conf && sed -i '35s/#T/T/' /etc/pacman.conf && sed -i '37s/#V/V/' /etc/pacman.conf && sleep 1 && exit"

	cont
}

function browser {
	br
	read -r -p "Install firefox? [y/N] " ff
	case "$ff" in
		[yY][eE][sS]|[yY])
			arch-chroot /mnt bash -c "pacman -S firefox && exit"
			;;
		*)
			;;
	esac
	read -r -p "Install firefox nightly? [y/N]" ffn
	case "$ffn" in
	    [yY][eE][sS]|[yY])
		    arch-chroot /mnt bash -c "pacman -S firefox-nightly && exit"
			;;
        *)
		    ;;
	esac
	read -r -p "Install chromium? [y/N] " chrom
	case "$chrom" in
		[yY][eE][sS]| [yY])
			arch-chroot /mnt bash -c "pacman -S chromium && exit"
			;;
		*)
			;;
	esac
	cont
}

function install-amd {
	pacstrap /mnt mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
	pacstrap /mnt libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau
}
function install-intel {
	arch-chroot /mnt bash -c "pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel" 
	arch-chroot /mnt bash -c "pacman -S libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau && exit"
}
function install-nvidia {
	br
	read -r -p "Do you want proprietary nvidia drivers? [y/N] " graphic
	case "$graphic" in
		[yY][eE][sS]|[yY])
			pacstrap /mnt nvidia nvidia-settings nvidia-utils lib32-nvidia-utils
			;;
		*)
			;;
	esac
	cont
}

function graphics {
	br
	echo -e "Choose Graphic card drivers to install: \n"
	echo -e "1. AMD \n2. Nvidia \n3. Intel \n4. None"
	read -r -p "Drivers [1/2/3/4]: " drivers
	case "$drivers" in
		1)
			install-amd
			;;
		2)
			install-nvidia
			;;
		3)
		    install-intel
			;;
		*)
			;;
	esac
	cont
}

function installsteam {
	br
	read -r -p "Do you want to install steam? [y/N] " isteam
	case "$isteam" in
		[yY][eE][sS]|[yY])
			pacstrap /mnt steam steam-native-runtime
			;;
		*)
			;;
	esac
	cont
}

function additional {
	br
	read -r -p "Do you want to install fun stuff? [y/N] " funyes # because why not
	case "$funyes" in
		[yY][eE][sS]|[yY])
			pacstrap /mnt sl neofetch lolcat cmatrix
			;;
		*)
			;;
	esac
}

function chaotic-aur {
	br 
	read -r -p "Do you want to add the Chaotic-aur repo [Y/n] " chaotic
	case "$chaotic" in 
	    [Yy][eE][sS]|[yY])
		    arch-chroot /mnt bash -c "pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com && pacman-key --lsign-key FBA220DFC880C036 && exit" 
			arch-chroot /mnt bash -c "pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' && exit"
			arch-chroot /mnt bash -c "echo '[chaotic-aur]' >> /etc/pacman.conf && echo Include = '/etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf && pacman -Sy && exit"
	esac
	cont
}

function full-installation {
	set-time
	partition
	mounting
	base
	archroot
	chaotic-aur
    set-timezone
	de
	installgrub
	graphics
	installsteam
	additional
	browser
	echo "Installation complete. Reboot you lazy bastard."
}

function step-installation {
	echo "These steps are available for installion:"
	echo "1. set-time"
	echo "2. partioning"
	echo "3. mounting"
	echo "4. base installation"
	echo "5. archroot"
	echo "6. adding chaotic-aur repo"
    echo "7. set-timezone"
	echo "8. installing a Desktop Environment"
	echo "9. installing grub"
	echo "10. graphics drivers"
	echo "11. installing steam"
	echo "12. additional stuff"
	echo "13. installing browsers"
	read -r -p "Enter the number of step : " stepno

	array=(set-time partition mounting base archroot chaotic-aur set-timezone de installgrub graphics installsteam additional browser)
	#array=(ascii ascii ascii)
	stepno=$[$stepno-1]
	while [ $stepno -lt ${#array[*]} ]
	do
		${array[$stepno]}
		stepno=$[$stepno+1]
	done
}

function main {
	echo "1. Start full installation"
	echo "2. Start from a specific step"
	read -r -p "What would you like to do? [1/2] " what
	case "$what" in
		2)
			step-installation
			;;
		*)
			full-installation
			;;
	esac
}

ascii
read -r -p "Start Installation? [Y/n] " starti
case "$starti" in
	[nN][oO]|[nN])
		;;
	*)
		main
		;;
esac
