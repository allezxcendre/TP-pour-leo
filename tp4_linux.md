# Partie 1 : Partitionnement du serveur de stockage

> Cette partie est à réaliser sur 🖥️ **VM storage.tp4.linux**.

On va ajouter un disque dur à la VM, puis le partitionner, afin de créer un espace dédié qui accueillera nos sites web.

➜ **Ajouter un disque dur de 2G à la VM**

- cela se fait via l'interface graphique de virtualbox
- il faut éteindre la VM pour ce faire

> [**Référez-vous au mémo LVM pour réaliser le reste de cette partie.**](../../../cours/memos/lvm.md)

**Le partitionnement est obligatoire pour que le disque soit utilisable.** Ici on va rester simple : une seule partition, qui prend toute la place offerte par le disque.

Comme vu en cours, le partitionnement dans les systèmes GNU/Linux s'effectue généralement à l'aide de *LVM*.

**Allons !**

![Part please](../pics/part_please.jpg)

🌞 **Partitionner le disque à l'aide de LVM**

- créer un *physical volume (PV)* : le nouveau disque ajouté à la VM

[user@vm dev]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
  
- créer un nouveau *volume group (VG)*
  - il devra s'appeler `storage`
  - il doit contenir le PV créé à l'étape précédente
  
  [user@vm dev]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
  
- créer un nouveau *logical volume (LV)* : ce sera la partition utilisable

- [user@vm dev]$  sudo lvcreate -l 100%FREE storage -n data_tp4
  Logical volume "data_tp4" created.

  - elle doit être dans le VG `storage`
  - elle doit occuper tout l'espace libre

🌞 **Formater la partition**

- vous formaterez la partition en ext4 (avec une commande `mkfs`)
  - le chemin de la partition, vous pouvez le visualiser avec la commande `lvdisplay`
  - pour rappel un *Logical Volume (LVM)* **C'EST** une partition
  - 
  [user@vm storage]$ sudo mkfs -t ext4 /dev/storage/data_tp4
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 527360 4k blocks and 131920 inodes
Filesystem UUID: ed5a4c01-b4de-467f-9f7f-0a0fb879c994
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

🌞 **Monter la partition**

- montage de la partition (avec la commande `mount`)
  - la partition doit être montée dans le dossier `/storage`
  - preuve avec une commande `df -h` que la partition est bien montée

[user@vm storage]$ mount /dev/storage/data_tp4 /mnt/data1

[user@vm storage]$ sudo mount /dev/storage/data_tp4 /mnt/data1

[user@vm storage]$ sudo df -h | grep tp4
/dev/mapper/storage-data_tp4  2.0G   24K  1.8G   1% /mnt/data1



  - prouvez que vous pouvez lire et écrire des données sur cette partition

[user@vm data1]$ ls
lost+found  toto

[user@vm data1]$ cat toto
tout marche c'est nickel!

- définir un montage automatique de la partition (fichier `/etc/fstab`)
  - vous vérifierez que votre fichier `/etc/fstab` fonctionne correctement
  - 
[user@vm /]$ sudo vim etc/fstab
/dev/storage/data_tp4  mnt/data1/ ext4 defaults 0 0

[user@vm /]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/data1 does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
mnt/data1/               : successfully mounted

Ok ! Za, z'est fait. On a un espace de stockage dédié pour stocker nos sites web.

**Passons à [la partie 2 : installation du serveur de partage de fichiers](./../part2/README.md).**
# Partie 2 : Serveur de partage de fichiers

**Dans cette partie, le but sera de monter un serveur de stockage.** Un serveur de stockage, ici, désigne simplement un serveur qui partagera un dossier ou plusieurs aux autres machines de son réseau.

Ce dossier sera hébergé sur la partition dédiée sur la machine **`storage.tp4.linux`**.

Afin de partager le dossier, **nous allons mettre en place un serveur NFS** (pour Network File System), qui est prévu à cet effet. Comme d'habitude : c'est un programme qui écoute sur un port, et les clients qui s'y connectent avec un programme client adapté peuvent accéder à un ou plusieurs dossiers partagés.

Le **serveur NFS** sera **`storage.tp4.linux`** et le **client NFS** sera **`web.tp4.linux`**.

L'objectif :

- avoir deux dossiers sur **`storage.tp4.linux`** partagés
  - `/storage/site_web_1/`
  - `/storage/site_web_2/`
- la machine **`web.tp4.linux`** monte ces deux dossiers à travers le réseau
  - le dossier `/storage/site_web_1/` est monté dans `/var/www/site_web_1/`
  - le dossier `/storage/site_web_2/` est monté dans `/var/www/site_web_2/`

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

[user@vm /]$ sudo dnf install nfs-utils
[user@vm /]$ sudo mkdir /storage/site_web_1/ -p
[user@vm storage]$ sudo mkdir /storage/site_web_2/ -p
[user@vm /]$ sudo chown nobody /storage/site_web_1
[user@vm /]$ sudo chown nobody /storage/site_web_2
[user@vm /]$ sudo nano /etc/exports
[user@vm /]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: d>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Mon 2023-01-02 10:52:50 CET; 18s ago
[user@vm /]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client
[user@vm /]$ sudo firewall-cmd --permanent --add-service=nfs
success
[user@vm /]$ sudo firewall-cmd --permanent --add-service=mountd
success
[user@vm /]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[user@vm /]$ sudo firewall-cmd --reload
success
[user@vm /]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind


- contenu du fichier `/etc/exports` dans le compte-rendu notamment

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

[user@vm ~]$ sudo mkdir -p /var/www/site_web_1/
[user@vm ~]$ sudo mkdir -p /var/www/site_web_2/
[user@vm ~]$ sudo mount 10.3.2.3:/storage/site_web_1 /var/www/site_web_1
[user@vm ~]$ sudo mount 10.3.2.3:/storage/site_web_2 /var/www/site_web_2

[user@vm ~]$ df -h
Filesystem                    Size  Used Avail Use% Mounted on
devtmpfs                      869M     0  869M   0% /dev
tmpfs                         888M     0  888M   0% /dev/shm
tmpfs                         356M  5.0M  351M   2% /run
/dev/mapper/rl-root           6.2G  1.2G  5.1G  20% /
/dev/sda1                    1014M  272M  743M  27% /boot
tmpfs                         178M     0  178M   0% /run/user/1000
10.3.2.3:/storage/site_web_1  6.2G  1.2G  5.1G  20% /storage/site_web_1
10.3.2.3:/storage/site_web_2  6.2G  1.2G  5.1G  20% /var/www/site_web_2

[user@vm site_web_1]$ sudo nano test1
[user@vm site_web_1]$ ls
test1
[user@vm site_web_1]$ cd ..
[user@vm www]$ cd site_web_2
[user@vm site_web_2]$ sudo nano test2
[user@vm site_web_2]$ ls -l /var/www/site_web_1/test1
-rw-r--r--. 1 root root 4 Jan  2 12:01 /var/www/site_web_1/test1
[user@vm site_web_2]$ ls -l /var/www/site_web_2/test2
-rw-r--r--. 1 root root 4 Jan  2 12:01 /var/www/site_web_2/test2
[user@vm ~]$ sudo nano /etc/fstab
dans le dossier:
10.3.2.3:/var/www/site_web_1 /www/site_web_1
10.3.2.3:/storage /var/www/site_web_2

- contenu du fichier `/etc/fstab` dans le compte-rendu notamment

> Je vous laisse vous inspirer de docs sur internet **[comme celle-ci](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9)** pour mettre en place un serveur NFS.

**Ok, on a fini avec la partie 2, let's head to [the part 3](./../part3/README.md).**


# Partie 3 : Serveur web

- [Partie 3 : Serveur web](#partie-3--serveur-web)
  - [1. Intro NGINX](#1-intro-nginx)
  - [2. Install](#2-install)
  - [3. Analyse](#3-analyse)
  - [4. Visite du service web](#4-visite-du-service-web)
  - [5. Modif de la conf du serveur web](#5-modif-de-la-conf-du-serveur-web)
  - [6. Deux sites web sur un seul serveur](#6-deux-sites-web-sur-un-seul-serveur)

## 1. Intro NGINX

![gnignigggnnninx ?](../pics/ngnggngngggninx.jpg)

**NGINX (prononcé "engine-X") est un serveur web.** C'est un outil de référence aujourd'hui, il est réputé pour ses performances et sa robustesse.

Un serveur web, c'est un programme qui écoute sur un port et qui attend des requêtes HTTP. Quand il reçoit une requête de la part d'un client, il renvoie une réponse HTTP qui contient le plus souvent de l'HTML, du CSS et du JS.

> Une requête HTTP c'est par exemple `GET /index.html` qui veut dire "donne moi le fichier `index.html` qui est stocké sur le serveur". Le serveur renverra alors le contenu de ce fichier `index.html`.

Ici on va pas DU TOUT s'attarder sur la partie dév web étou, une simple page HTML fera l'affaire.

Une fois le serveur web NGINX installé (grâce à un paquet), sont créés sur la machine :

- **un service** (un fichier `.service`)
  - on pourra interagir avec le service à l'aide de `systemctl`
- **des fichiers de conf**
  - comme d'hab c'est dans `/etc/` la conf
  - comme d'hab c'est bien rangé, donc la conf de NGINX c'est dans `/etc/nginx/`
  - question de simplicité en terme de nommage, le fichier de conf principal c'est `/etc/nginx/nginx.conf`
- **une racine web**
  - c'est un dossier dans lequel un site est stocké
  - c'est à dire là où se trouvent tous les fichiers PHP, HTML, CSS, JS, etc du site
  - ce dossier et tout son contenu doivent appartenir à l'utilisateur qui lance le service
- **des logs**
  - tant que le service a pas trop tourné c'est empty
  - les fichiers de logs sont dans `/var/log/`
  - comme d'hab c'est bien rangé donc c'est dans `/var/log/nginx/`
  - on peut aussi consulter certains logs avec `sudo journalctl -xe -u nginx`

> Chaque log est à sa place, on ne trouve pas la même chose dans chaque fichier ou la commande `journalctl`. La commande `journalctl` vous permettra de repérer les erreurs que vous glisser dans les fichiers de conf et qui empêche le démarrage correct de NGINX.

## 2. Install

🖥️ **VM web.tp4.linux**

🌞 **Installez NGINX**


[user@tp4web ~]$ sudo dnf install nginx

## 3. Analyse

Avant de config des truks 2 ouf étou, on va lancer à l'aveugle et inspecter ce qu'il se passe, inspecter avec les outils qu'on connaît ce que fait NGINX à notre OS.

Commencez donc par démarrer le service NGINX :

```bash
$ sudo systemctl start nginx
$ sudo systemctl status nginx
```

🌞 **Analysez le service NGINX**
[user@tp4web ~]$ ps -ef | grep nginx
root         908       1  0 14:12 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx        909     908  0 14:12 ?        00:00:00 nginx: worker process
murci        917     875  0 14:12 pts/0    00:00:00 grep --color=auto nginx
[user@tp4web ~]$ sudo ss -alnp | grep nginx
tcp   LISTEN 0      511                                       0.0.0.0:80               0.0.0.0:*     users:(("nginx",pid=909,fd=6),("nginx",pid=908,fd=6))

tcp   LISTEN 0      511                                          [::]:80                  [::]:*     users:(("nginx",pid=909,fd=7),("nginx",pid=908,fd=7))

[murci@tp4web ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /usr/share/nginx/html;
#        root         /usr/share/nginx/html;

[user@tp4web ~]$ ls -al /usr/share/nginx/html/
total 12
drwxr-xr-x. 3 root root  143 Dec  9 15:57 .
drwxr-xr-x. 4 root root   33 Dec  9 15:57 ..
-rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
-rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
drwxr-xr-x. 2 root root   27 Dec  9 15:57 icons
lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png
## 4. Visite du service web

**Et ça serait bien d'accéder au service non ?** Genre c'est un serveur web. On veut voir un site web !

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

[user@tp4web ~]$ sudo firewall-cmd --list-all | grep 80
  ports: 80/tcp 22/tcp

🌞 **Accéder au site web**

PS C:\Users\user> curl http://192.168.56.5:80


StatusCode        : 200
StatusDescription : OK
Content           : <!doctype html>
                    <html>
                      <head>
                        <meta charset='utf-8'>
                        <meta name='viewport' content='width=device-width,
                    initial-scale=1'>
                        <title>HTTP Server Test Page powered by: Rocky
                    Linux</title>
                       ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 7620
                    Content-Type: text/html
                    Date: Sat, 10 Dec 2022 13:25:59 GMT
                    ETag: "62e17e64-1dc4"
                    Last-Modified: Wed, 27 Jul 202...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 7620], [Content-Type, text/html]...}
Images            : {@{innerHTML=; innerText=; outerHTML=<IMG alt="[
                    Powered by Rocky Linux ]" src="icons/poweredby.png">;
                    outerText=; tagName=IMG; alt=[ Powered by Rocky Linux
                    ]; src=icons/poweredby.png}, @{innerHTML=; innerText=;
                    outerHTML=<IMG src="poweredby.png">; outerText=;
                    tagName=IMG; src=poweredby.png}}
InputFields       : {}
Links             : {@{innerHTML=<STRONG>Rocky Linux website</STRONG>;
                    innerText=Rocky Linux website; outerHTML=<A
                    href="https://rockylinux.org/"><STRONG>Rocky Linux
                    website</STRONG></A>; outerText=Rocky Linux website;
                    tagName=A; href=https://rockylinux.org/},
                    @{innerHTML=Apache Webserver</STRONG>;
                    innerText=Apache Webserver; outerHTML=<A
                    href="https://httpd.apache.org/">Apache
                    Webserver</STRONG></A>; outerText=Apache Webserver;
                    tagName=A; href=https://httpd.apache.org/},
                    @{innerHTML=Nginx</STRONG>; innerText=Nginx;
                    outerHTML=<A
                    href="https://nginx.org">Nginx</STRONG></A>;
                    outerText=Nginx; tagName=A; href=https://nginx.org},
                    @{innerHTML=<IMG alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png">; innerText=; outerHTML=<A
                    id=rocky-poweredby href="https://rockylinux.org/"><IMG
                    alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png"></A>; outerText=; tagName=A;
                    id=rocky-poweredby; href=https://rockylinux.org/}...}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 7620
> Si le port c'est 80, alors c'est la convention pour HTTP. Ainsi, il est inutile de le préciser dans l'URL, le navigateur le fait de lui-même. On peut juste saisir `http://<IP_VM>`.

🌞 **Vérifier les logs d'accès**

[user@tp4web ~]$ sudo cat /var/log/nginx/access.log | tail -n 3
192.168.56.1 - - [10/Dec/2022:14:28:24 +0100] "GET /icons/poweredby.png HTTP/1.1" 200 15443 "http://192.168.56.5/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 OPR/93.0.0.0" "-"
192.168.56.1 - - [10/Dec/2022:14:28:24 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://192.168.56.5/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 OPR/93.0.0.0" "-"
192.168.56.1 - - [10/Dec/2022:14:28:24 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://192.168.56.5/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 OPR/93.0.0.0" "-"

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

[user@tp4web ~]$ sudo cat /etc/nginx/nginx.conf | grep 8080
        listen       8080;


[user@tp4web ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendo>
     Active: active (running) since Sat 2022-12-10 19:27:11 CET; 13s ago
     
     [user@tp4web ~]$ sudo ss -alnp | grep nginx
tcp   LISTEN 0      511                                       0.0.0.0:8080             0.0.0.0:*     users:(("nginx",pid=914,fd=6),("nginx",pid=913,fd=6))
tcp   LISTEN 0      511                                          [::]:80                  [::]:*     users:(("nginx",pid=914,fd=7),("nginx",pid=913,fd=7))
     
     
     [user@tp4web ~]$ sudo firewall-cmd --list-all | grep 8080
  ports: 22/tcp 8080/tcp
  
  
  PS C:\Users\user> curl http://192.168.56.5:8080                            

StatusCode        : 200
StatusDescription : OK
Content           : <!doctype html>
                    <html>
                      <head>
                        <meta charset='utf-8'>
                        <meta name='viewport' content='width=device-width,
                    initial-scale=1'>
                        <title>HTTP Server Test Page powered by: Rocky
                    Linux</title>
                       ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 7620
                    Content-Type: text/html
                    Date: Sat, 10 Dec 2022 18:32:29 GMT
                    ETag: "62e17e64-1dc4"
                    Last-Modified: Wed, 27 Jul 202...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 7620], [Content-Type, text/html]...}
Images            : {@{innerHTML=; innerText=; outerHTML=<IMG alt="[
                    Powered by Rocky Linux ]" src="icons/poweredby.png">;
                    outerText=; tagName=IMG; alt=[ Powered by Rocky Linux
                    ]; src=icons/poweredby.png}, @{innerHTML=; innerText=;
                    outerHTML=<IMG src="poweredby.png">; outerText=;
                    tagName=IMG; src=poweredby.png}}
InputFields       : {}
Links             : {@{innerHTML=<STRONG>Rocky Linux website</STRONG>;
                    innerText=Rocky Linux website; outerHTML=<A
                    href="https://rockylinux.org/"><STRONG>Rocky Linux
                    website</STRONG></A>; outerText=Rocky Linux website;
                    tagName=A; href=https://rockylinux.org/},
                    @{innerHTML=Apache Webserver</STRONG>;
                    innerText=Apache Webserver; outerHTML=<A
                    href="https://httpd.apache.org/">Apache
                    Webserver</STRONG></A>; outerText=Apache Webserver;
                    tagName=A; href=https://httpd.apache.org/},
                    @{innerHTML=Nginx</STRONG>; innerText=Nginx;
                    outerHTML=<A
                    href="https://nginx.org">Nginx</STRONG></A>;
                    outerText=Nginx; tagName=A; href=https://nginx.org},
                    @{innerHTML=<IMG alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png">; innerText=; outerHTML=<A
                    id=rocky-poweredby href="https://rockylinux.org/"><IMG
                    alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png"></A>; outerText=; tagName=A;
                    id=rocky-poweredby; href=https://rockylinux.org/}...}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 7620
🌞 **Changer l'utilisateur qui lance le service**

[user@tp4web ~]$ sudo useradd web -m
[murci@tp4web ~]$ sudo passwd web
Changing password for user web.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
[user@tp4web ~]$ cat /etc/passwd | grep web
nginx:x:991:991:Nginx web server:/var/lib/nginx:/sbin/nologin
web:x:1001:1001::/home/web:/bin/bash

---
[user@tp4web ~]$ sudo cat /etc/nginx/nginx.conf | grep web
user web;

[user@tp4web ~]$ sudo systemctl restart nginx
**Il est temps d'utiliser ce qu'on a fait à la partie 2 !**

[user@tp4web ~]$ sudo ps -ef | grep nginx
root        1002       1  0 19:43 ?        00:00:00 nginx: master process /usr/sbin/nginx
web         1003    1002  0 19:43 ?        00:00:00 nginx: worker process
murci       1005     870  0 19:43 pts/0    00:00:00 grep --color=auto nginx

🌞 **Changer l'emplacement de la racine Web**

[user@tp4web ~]$ sudo cat /etc/nginx/nginx.conf | grep site_web_1
        root         /var/www/site_web_1/;
        
        [murci@tp4web ~]$ sudo systemctl restart nginx
        
        PS C:\Users\darkj> curl http://192.168.56.5:8080                            

StatusCode        : 200
StatusDescription : OK
Content           : <! DOCTYPE html>
                    <html>
                            <head>
                                    <title>OE OE ma page</title>
                            </head>
                            <body>
                            <h1>OE OE ma page</h1>
                            <p>Mon site web ^^</p>
                            </body>
                    </html>
                    ...

> **Normalement le dossier `/var/www/site_web_1/` est un dossier créé à la Partie 2 du TP**, et qui se trouve en réalité sur le serveur `storage.tp4.linux`, notre serveur NFS.

![MAIS](../pics/nop.png)

## 6. Deux sites web sur un seul serveur

Dans la conf NGINX, vous avez du repérer un bloc `server { }` (si c'est pas le cas, allez le repérer, la ligne qui définit la racine web est contenu dans le bloc `server { }`).

Un bloc `server { }` permet d'indiquer à NGINX de servir un site web donné.

Si on veut héberger plusieurs sites web, il faut donc déclarer plusieurs blocs `server { }`.

**Pour éviter que ce soit le GROS BORDEL dans le fichier de conf**, et se retrouver avec un fichier de 150000 lignes, on met chaque bloc `server` dans un fichier de conf dédié.

Et le fichier de conf principal contient une ligne qui inclut tous les fichiers de confs additionnels.

🌞 **Repérez dans le fichier de conf**

[user@tp4web ~]$ sudo cat /etc/nginx/nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;

> On trouve souvent ce mécanisme dans la conf sous Linux : un dossier qui porte un nom finissant par `.d` qui contient des fichiers de conf additionnels pour pas foutre le bordel dans le fichier de conf principal. On appelle ce dossier un dossier de *drop-in*.

🌞 **Créez le fichier de configuration pour le premier site**

[user@tp4web ~]$ cat /etc/nginx/conf.d/site_web_1.conf
server {
        listen       8080;
        listen       [::]:80;
        server_name  _;
        root         /var/www/site_web_1/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
🌞 **Créez le fichier de configuration pour le deuxième site**

[user@tp4web ~]$ cat /etc/nginx/conf.d/site_web_2.conf
server {
        listen       8888;
        listen       [::]:80;
        server_name  _;
        root         /var/www/site_web_2/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
> N'oubliez pas d'ouvrir le port 8888 dans le firewall. Vous pouvez constater si vous le souhaitez avec un `ss` que NGINX écoute bien sur ce nouveau port.

🌞 **Prouvez que les deux sites sont disponibles**

site web n°1 ^^ :
PS C:\Users\user> curl http://192.168.56.5:8080


StatusCode        : 200
StatusDescription : OK
Content           : <! DOCTYPE html>
                            <head>
                                    <title>OE OE ma page</title>
                            </head>                                                                     <body>                                                                      <h1>OE OE ma page</h1>                                                      <p>Mon site web ^^</p>                                                      </body>
                    </html>...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 201
                    Content-Type: text/html
                    Date: Sat, 10 Dec 2022 19:33:34 GMT
                    ETag: "6394dccf-c9"
                    Last-Modified: Sat, 10 Dec 2022 1...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 201], [Content-Type, text/html]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 201

site web n°2 ^^ :
PS C:\Users\darkj> curl http://192.168.56.5:8888


StatusCode        : 200
StatusDescription : OK
Content           : <! DOCTYPE html>
                    <html>
                            <head>
                                    <title>OE OE ma page<title>
                            </head>
                            <body>
                            <h1>OE OE ma page</h1>
                            <p>Mon site web nÂ°2 ^^</p>
                            </body>
                    </h...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 205
                    Content-Type: text/html
                    Date: Sat, 10 Dec 2022 19:34:00 GMT
                    ETag: "6394db04-cd"
                    Last-Modified: Sat, 10 Dec 2022 1...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 205], [Content-Type, text/html]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 205
    }
