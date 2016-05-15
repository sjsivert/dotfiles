dir=~/dotfiles
olddir=~/dotfiles_old
files="bashrc vimrc  zshrc  dmenurc Xresources gtkrc-2.0"
folders="oh_my_zsh vim config"

# create backup folder

echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"echo "...done"

for file in $files; do
	echo "Copy $file  existing dotfiles from ~ to $olddir"
	mv ~/.$file ~/dotfiles_old
	echo "Creating symlink to $file in home directory"
	ln -s $dir/$file ~/.$file
done

for folder in $folders; do
	echo "backup $folder of folder"
	cp -r ~/.$folder $olddir
	echo "merge and overviret $folder to home"
	cp -r $dir/$folder ~/$folder
done

echo "Copy fonts"
cp $dir/fonts/* /usr/share/fonts/TTF/
# update fonts cache
fc-cache

echo "copy Scripts"
cp -r $dir/scripts ~/scripts