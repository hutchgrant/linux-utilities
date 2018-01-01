# Linux Server Backup

   tar -cpzf $BACKUPDIR/$BACKUPFILE --directory=/ \
      --exclude=/proc \
      --exclude=/tmp \
      --exclude=/sys \
      --exclude=/mnt \
      --exclude=/media \
      --exclude=/run \
      --exclude=/dev \
      --exclude=/var/cache/apt/archives \
      --exclude=/usr/src/linux-headers* \
      --exclude=/home/*/.gvfs \
      --exclude=/home/*/.cache \
      --exclude=/home/*/.local/share/Trash \
      --exclude=$BACKUPDIR $BACKUPSRC


# Linux Server Restore

sudo tar -xvpzf /path/to/backup.tar.gz -C /media/whatever --numeric-owner
