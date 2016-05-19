dir=~/dotfiles
olddir=~/dotfiles_old
files="bashrc vimrc  zshrc  dmenurc Xresources xinitrc gtkrc-2.0"
folders="oh-my-zsh vim config/git config/gtk-3.0 config/i3 config/sublime-text-3"

# create backup folder

echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

for file in $files; do
	echo "------"
	echo "Copy $file  existing dotfiles from ~ to $olddir"
	mv ~/.$file ~/dotfiles_old
	echo "Creating symlink to $file in home directory"
	ln -s $dir/$file ~/.$file
done

for folder in $folders; do
	echo "------------"
	echo "backup $folder folder"
	mv ~/.$folder $olddir
	echo "merge and overviret $folder to home"
	mkdir -p ~/.$folder
	ln -s $dir/$folder/* ~/.$folder
done

echo "Copy fonts"
echo "-----------------------------"
sudo cp $dir/fonts/* /usr/share/fonts/TTF/
# update fonts cache
fc-cache

echo "copy Scripts"
sudo cp -r $dir/scripts ~/scripts

