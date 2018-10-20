dir=~/dotfiles
olddir=~/dotfiles_old
files="bashrc vimrc  zshrc"
folders="oh-my-zsh vim config/git config/ranger"

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

echo "symlink Scripts"
ln -s $dir/scripts ~/scripts
