# TP 3 : We do a little scripting

Aujourd'hui un TP pour appréhender un peu **le scripting**.

➜ **Le scripting dans GNU/Linux**, c'est simplement le fait d'écrire dans un fichier une suite de commande, qui seront exécutées les unes à la suite des autres lorsque l'on exécutera le script.

Plus précisément, on utilisera la syntaxe du shell `bash`. Et on a le droit à l'algo (des variables, des conditions `if`, des boucles `while`, etc).

➜ **Bon par contre, la syntaxe `bash`, elle fait mal aux dents.** Ca va prendre un peu de temps pour s'habituer.

![Bash syntax](./pics/bash_syntax.jpg)

Pour ça, vous prenez connaissance des deux ressources suivantes :

- [le cours sur le shell](../../cours/shell/README.md)
- [le cours sur le scripting](../../cours/scripting/README.md)
- le très bon https://devhints.io/bash pour tout ce qui est relatif à la syntaxe `bash`

➜ **L'emoji 🐚** est une aide qui indique une commande qui est capable de réaliser le point demandé

## Sommaire

- [TP 3 : We do a little scripting](#tp-3--we-do-a-little-scripting)
  - [Sommaire](#sommaire)
- [0. Un premier script](#0-un-premier-script)
- [I. Script carte d'identité](#i-script-carte-didentité)
  - [Rendu](#rendu)
- [II. Script youtube-dl](#ii-script-youtube-dl)
  - [Rendu](#rendu-1)
- [III. MAKE IT A SERVICE](#iii-make-it-a-service)
  - [Rendu](#rendu-2)
- [IV. Bonus](#iv-bonus)

# 0. Un premier script

➜ **Créer un fichier `test.sh` dans le dossier `/srv/` avec le contenu suivant** :

```bash
#!/bin/bash
# Simple test script

echo "Connecté actuellement avec l'utilisateur $(whoami)."
```

> La première ligne est appelée le *shebang*. Cela indique le chemin du programme qui sera utilisé par le script. Ici on inscrit donc, pour un script `bash`, le chemin vers le programme `bash` mais c'est la même chose pour des scripts en Python, PHP, etc.

➜ **Modifier les permissions du script `test.sh`**

- si c'est pas déjà le cas, faites en sorte qu'il appartienne à votre utilisateur
  - 🐚 `chown`
- ajoutez la permission `x` pour votre utilisateur afin que vous puissiez exécuter le script
  - 🐚 `chmod`

➜ **Exécuter le script** :

```bash
# Exécuter le script, peu importe le dossier où vous vous trouvez
$ /srv/test.sh

# Exécuter le script, depuis le dossier où il est stocké
$ cd /srv
$ ./test.sh
```

> **Vos scripts devront toujours se présenter comme ça** : muni d'un *shebang* à la ligne 1 du script, appartenir à un utilisateur spécifique qui possède le droit d'exécution sur le fichier.

# I. Script carte d'identité

Vous allez écrire **un script qui récolte des informations sur le système et les affiche à l'utilisateur.** Il s'appellera `idcard.sh` et sera stocké dans `/srv/idcard/idcard.sh`.

> `.sh` est l'extension qu'on donne par convention aux scripts réalisés pour être exécutés avec `sh` ou `bash`.

➜ **Testez les commandes à la main avant de les incorporer au script.**

➜ Ce que doit faire le script. Il doit afficher :

- le **nom de la machine**
  - 🐚 `hostnamectl`
- le **nom de l'OS** de la machine
  - regardez le fichier `/etc/redhat-release` ou `/etc/os-release`
  - 🐚 `source`
- la **version du noyau** Linux utilisé par la machine
  - 🐚 `uname`
- l'**adresse IP** de la machine
  - 🐚 `ip`
- l'**état de la RAM**
  - 🐚 `free`
  - espace dispo en RAM (en Go, Mo, ou Ko)
  - taille totale de la RAM (en Go, Mo, ou ko)
- l'**espace restant sur le disque dur**, en Go (ou Mo, ou ko)
  - 🐚 `df`
- le **top 5 des processus** qui pompent le plus de RAM sur la machine actuellement. Procédez par étape :
  - 🐚 `ps`
  - listez les process
  - affichez la RAM utilisée par chaque process
  - triez par RAM utilisée
  - isolez les 5 premiers
- la **liste des ports en écoute** sur la machine, avec le programme qui est derrière
  - préciser, en plus du numéro, s'il s'agit d'un port TCP ou UDP
  - 🐚 `ss`
- un **lien vers une image/gif** random de chat 
  - 🐚 `curl`
  - il y a de très bons sites pour ça hihi
  - avec [celui-ci](https://cataas.com/), une simple requête HTTP vers `https://cataas.com/cat` vous retourne l'URL d'une random image de chat
    - une requête sur cette adresse retourne directement l'image, il faut l'enregistret dans un fichier
    - parfois le fichier est un JPG, parfois un PNG, parfois même un GIF
    - 🐚 `file` peut vous aider à déterminer le type de fichier

Pour vous faire manipuler les sorties/entrées de commandes, votre script devra sortir **EXACTEMENT** :

```
$ /srv/idcard/idcard.sh
Machine name : ...
OS ... and kernel version is ...
IP : ...
RAM : ... memory available on ... total memory
Disk : ... space left
Top 5 processes by RAM usage :
  - ...
  - ...
  - ...
  - ...
  - ...
Listening ports :
  - 22 tcp : sshd
  - ...
  - ...

Here is your random cat : ./cat.jpg
```

## Rendu

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 **Vous fournirez dans le compte-rendu**, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.




[user@tp3 ~]$ /srv/idcard/idcard.sh
Machine name : tp3
OS Rocky Linux and kernel version is 5.14.0-70.26.1.el9_0.x86_64
IP : 192.168.56.255
RAM : 579Mi memory available on 960Mi total memory
Disque : 5.1G space left
Top 5 processes by RAM usage :
  - /usr/bin/python3 (RAM utilisé : 3.9)
  - /usr/sbin/NetworkManager (RAM utilisé : 1.9)
  - /usr/lib/systemd/systemd (RAM utilisé : 1.7)
  - /usr/lib/systemd/systemd (RAM utilisé : 1.3)
  - sshd: (RAM utilisé : 1.2)
Listening ports :
  - 323 udp : chronyd
  - 22 tcp : sshd
Here is your random cat : ./cat.jpe

[fichier_test.sh](fichier_test.sh)
# II. Script youtube-dl


## Rendu

📁 **Le script `/srv/yt/yt.sh`**

[youtube.sh](youtube.sh)

📁 **Le fichier de log `/var/log/yt/download.log`**, avec au moins quelques lignes

[téléchargement](téléchargement)

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

[user@tp3 yt]$ /srv/yt/yt.sh https://youtu.be/9ZX1k4XhX24
Video https://youtu.be/9ZX1k4XhX24 was downloaded.
File path : /srv/yt/downloads/chat qui miaule/chat qui miaule.mp4

[user@tp3 ~]$ /srv/yt/yt.sh https://www.youtube.com/watch?v=GBIIQ0kP15E
Video https://www.youtube.com/watch?v=GBIIQ0kP15E was downloaded.
File path : /srv/yt/downloads/Rickroll (Meme Template)/Rickroll (Meme Template).mp4

[user@tp3 ~]$ /srv/yt/yt.sh https://www.youtube.com/watch?v=7NNJQJXNO5I
Video https://www.youtube.com/watch?v=7NNJQJXNO5I was downloaded.
File path : /srv/yt/downloads/Bleach: Fade to Black - Fade to Black B13a 【Intense Symphonic Metal Cover】/Bleach: Fade to Black - Fade to Black B13a 【Intense Symphonic Metal Cover】.webm

# III. MAKE IT A SERVICE

YES. Yet again. **On va en faire un [service](../../cours/notions/serveur/README.md#ii-service).**

L'idée :

➜ plutôt que d'appeler la commande à la main quand on veut télécharger une vidéo, **on va créer un service qui les téléchargera pour nous**

➜ le service devra **lire en permanence dans un fichier**

- s'il trouve une nouvelle ligne dans le fichier, il vérifie que c'est bien une URL de vidéo youtube
  - si oui, il la télécharge, puis enlève la ligne
  - sinon, il enlève juste la ligne

➜ **qui écrit dans le fichier pour ajouter des URLs ? Bah vous !**

- vous pouvez écrire une liste d'URL, une par ligne, et le service devra les télécharger une par une

---

Pour ça, procédez par étape :

- **partez de votre script précédent** (gardez une copie propre du premier script, qui doit être livré dans le dépôt git)
  - le nouveau script s'appellera `yt-v2.sh`
- **adaptez-le pour qu'il lise les URL dans un fichier** plutôt qu'en argument sur la ligne de commande
- **faites en sorte qu'il tourne en permanence**, et vérifie le contenu du fichier toutes les X secondes
  - boucle infinie qui :
    - lit un fichier
    - effectue des actions si le fichier n'est pas vide
    - sleep pendant une durée déterminée
- **il doit marcher si on précise une vidéo par ligne**
  - il les télécharge une par une
  - et supprime les lignes une par une

➜ **une fois que tout ça fonctionne, enfin, créez un service** qui lance votre script :

- créez un fichier `/etc/systemd/system/yt.service`. Il comporte :
  - une brève description
  - un `ExecStart` pour indiquer que ce service sert à lancer votre script
  - une clause `User=` pour indiquer que c'est l'utilisateur `yt` qui lance le script
    - créez l'utilisateur s'il n'existe pas
    - faites en sorte que le dossier `/srv/yt` et tout son contenu lui appartienne
    - le dossier de log doit lui appartenir aussi
    - l'utilisateur `yt` ne doit pas pouvoir se connecter sur la machine

```bash
[Unit]
Description=<Votre description>

[Service]
ExecStart=<Votre script>
User=yt

[Install]
WantedBy=multi-user.target
```

> Pour rappel, après la moindre modification dans le dossier `/etc/systemd/system/`, vous devez exécuter la commande `sudo systemctl daemon-reload` pour dire au système de lire les changements qu'on a effectué.

Vous pourrez alors interagir avec votre service à l'aide des commandes habituelles `systemctl` :

- `systemctl status yt`
- `sudo systemctl start yt`
- `sudo systemctl stop yt`

![Now witness](./pics/now_witness.png)

## Rendu

📁 **Le script `/srv/yt/yt-v2.sh`**

[youtube2](youtube2)

📁 **Fichier `/etc/systemd/system/yt.service`**

[youtube_service](youbube_service)

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

[user@tp3 ~]$ systemctl status yt
● yt.service - Telechargement de videos YouTube
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor prese>
     Active: active (running) since Mon 2022-12-05 06:29:51 CET; 13min ago
   Main PID: 28792 (yt-v2.sh)
      Tasks: 2 (limit: 5907)
     Memory: 580.0K
        CPU: 160ms
     CGroup: /system.slice/yt.service
             ├─28792 /bin/bash /srv/yt/yt-v2.sh
             └─28969 sleep 5``





Dec 05 06:29:51 tp3 systemd[1]: Started Telechargement de videos YouTube.
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit yt.service has finished successfully.
░░
░░ The job identifier is 3826.
Dec 05 06:52:40 tp3 yt-v2.sh[28792]: Video https://www.youtube.com/watch?v=P3RNPoQIX0M was downloaded.
Dec 05 06:52:40 tp3 yt-v2.sh[28792]: File path : /srv/yt/downloads/Zaraki Kenpachi Appears - Bleach: TYBW Episode 5 [On the Precipice of Defeat ] (HQ Cover)/Zaraki Kenpachi Appears - Bleach: TYBW Episode 5 [On the Precipice of Defeat ] (HQ Cover).mp4