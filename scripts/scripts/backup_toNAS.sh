rsync -aAxv --password-file /home/archie/scripts/pw_nas.txt --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/archie/.cache","/var/cache"} / admin@192.168.0.114::Qweb/backup_arch-home
 

