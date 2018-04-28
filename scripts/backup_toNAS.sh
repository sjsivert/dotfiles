rsync -aAxv --password-file ~/scripts/pw_nas.txt --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/archie/.cache","/var/cache"} / admin@192.168.1.12::Qweb/backup_arch-home
 

