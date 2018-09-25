dir=~/dotfiles
olddir=~/dotfiles_old
files="bashrc vimrc  zshrc  dmenurc Xresources xinitrc gtkrc-2.0 compton.conf"
folders="oh-my-zsh vim config/git config/gtk-3.0 config/i3 config/sublime-text-3 config/ranger"

# create backup folder

echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir

# change to the dotfiles directory
#echo "Changing to the $dir directory"
#cd $dir

for file in $files; do
	echo "------"
	echo "move $file from ~ to $olddir"
	mv ~/.$file $olddir
	echo "Creating symlink to $file"
	ln -s $dir/$file ~/.$file
done

for folder in $folders; do
	echo "------------"
	echo "move $folder to $olddir"
	mv ~/.$folder $olddir
	echo "merge and overviret $folder to home"
	#mkdir -p ~/.$folder
	ln -s $dir/$folder ~/.$folder
done

echo "Copy fonts"
echo "-----------------------------"
sudo cp -n $dir/fonts/* /usr/share/fonts/TTF/
# update fonts cache
fc-cache

echo "symlink Scripts"
ln -s $dir/scripts ~/scripts
