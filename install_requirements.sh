pacman=" gnome-themes-standard 
gtk-engine-murrine
rxvt-unicode
feh
compton
pavucontrol
sysstat"


pacaur="i3-gaps
gtk-theme-arc
numix-icon-theme-git
xcursor-chameleon-pearl
i3blocks-gaps-git
rofi-git
pulseaudio
pulseaudio-ctl
i3lock-color-git
j4-dmenu-desktop
vundle"
pip="the-fuck"
sudo pacman -S $pacman
yaourt -S --noconfirm $pacaur
pip install $pip
