#!/bin/bash

logfile='/var/log/yt/download.log'
if [[ ! -f $logfile ]]
then
        echo "Creer un fichier downloads.log dans /var/log/yt/"
        exit 0
fi
dl='/srv/yt/downloads'
if [[ ! -d $dl ]]
then
        echo "Creer un dossier downloads dans /srv/yt"
        exit 0
fi
while true
do
        if [[ -s /srv/yt/urls ]]
        then
                while read -r ligne
                do
                        title="$(youtube-dl --get-title $ligne)"
                        filename="$(youtube-dl --get-filename $ligne | cut -d'.' -f2)"
                        mkdir /srv/yt/downloads/"$title"
                        youtube-dl -o /srv/yt/downloads/"$title"/"$title.$filename" $ligne > /dev/null
                        youtube-dl --get-description $ligne > /srv/yt/downloads/"$title"/description
                        echo "Video $ligne was downloaded."
                        echo File path : /srv/yt/downloads/"$title"/"$title.$filename"
                        echo [$(date "+%D %T")] Video $ligne was downloaded. File path : /srv/yt/downloads/"$title"/"$title.$filename" >> $logfile
                done <<< "$(cat /srv/yt/urls)"
                cat /dev/null > /srv/yt/urls
        else
                sleep 5
        fi
done
Footer
© 2022 GitHub, Inc.
