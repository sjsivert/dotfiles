pacman=" gnome-themes-standard 
gtk-engine-murrine
libgnome-keyring
gnome-keyring
xautolock
rxvt-unicode
feh
polkit-gnome
compton
pavucontrol
sysstat
ranger
w3m
rofi
redshift
thunar
xfce4-settings
xfce4-power-manager
xfsettingsd
imagemagick
xorg-xdpyinfo
bc
mediainfo"
#lxappearence"


pakku="i3-gaps
i3lock-color
arc-gtk-theme
nitrogen
playerctl
cava-git
numix-icon-theme-git
xcursor-chameleon-pearl
i3blocks-gaps-git
i3lock-fancy-git
rofi-git
pulseaudio
pulseaudio-ctl
i3lock-color-git
j4-dmenu-desktop
vundle
i3-lock-fancy-dualmonitors-git"
pip="the-fuck"
sudo pacman -S $pacman
pakku -S --noconfirm $pakku
pip install $pip
