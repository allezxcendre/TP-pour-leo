#!/bin/bash

logfile='/var/log/yt/download.log'
if [[ ! -f $logfile ]]
then
  echo "Creer un fichier downloads.log dans /var/log/yt/"
  exit 0
fi
dir='/srv/yt/downloads'
if [[ ! -d $dir ]]
then
  echo "Creer un dossier downloads dans /srv/yt"
  exit 0
fi
if [[ -z "$1" ]]
then
        echo "Mettez le lien de la vidéo à dl juste après la commande"
        exit 0
fi
title="$(youtube-dl --get-title $1)"
filename="$(youtube-dl --get-filename $1 | cut -d'.' -f2)"
mkdir /srv/yt/downloads/"$title"
youtube-dl -o /srv/yt/downloads/"$title"/"$title.$filename" $1 > /dev/null
youtube-dl --get-description $1 > /srv/yt/downloads/"$title"/description
echo "Video $1 was downloaded."
echo File path : /srv/yt/downloads/"$title"/"$title.$filename"
echo [$(date "+%D %T")] Video $1 was downloaded. File path : /srv/yt/downloads/"$title"/"$title.$filename" >> $logfile
