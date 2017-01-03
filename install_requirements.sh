pacman=" gnome-themes-standard 
gtk-engine-murrine
rxvt-unicode
feh
compton
pavucontrol
sysstat
ranger
w3m
mediainfo
lxappearence"


pacaur="i3-gaps
gtk-theme-arc
nitrogen
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
yaourt -S --noconfirm $pacaur
pip install $pip
