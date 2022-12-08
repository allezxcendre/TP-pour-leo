# TP2 : Appréhender l'environnement Linux

Dans ce TP, on va aborder plusieurs sujets, dans le but principal de se familiariser un peu plus avec l'environnement GNU/Linux.

> Pour rappel, nous étudions et utilisons GNU/Linux de l'angle de l'administrateur, qui gère des serveurs. Nous n'allons que très peu travailler avec des distributions orientées client. Rocky Linux est parfaitement adapté à cet usage.

Ce que vous faites dans ce TP deviendra peu à peu naturel au fil des cours et de votre utilsation de GNU/Linux.

Comme d'hab rien à savoir par coeur, jouez le jeu, et la plasticité de votre cerveau fera le reste.

Une seule VM Rocky suffit pour ce TP. N'oubliez pas d'ouvrir les ports firewall quand c'est nécessaire. De façon volontaire, je ne le précise pas à chaque fois.  
Ca doit devenir naturel : vous lancez un programme pour écouter sur un port, alors il faut ouvrir ce port.

# Sommaire

- [TP2 : Appréhender l'environnement Linux](#tp2--appréhender-lenvironnement-linux)
- [Sommaire](#sommaire)
  - [Checklist](#checklist)
- [I. Service SSH](#i-service-ssh)
  - [1. Analyse du service](#1-analyse-du-service)
  - [2. Modification du service](#2-modification-du-service)
- [II. Service HTTP](#ii-service-http)
  - [1. Mise en place](#1-mise-en-place)
  - [2. Analyser la conf de NGINX](#2-analyser-la-conf-de-nginx)
  - [3. Déployer un nouveau site web](#3-déployer-un-nouveau-site-web)
- [III. Your own services](#iii-your-own-services)
  - [1. Au cas où vous auriez oublié](#1-au-cas-où-vous-auriez-oublié)
  - [2. Analyse des services existants](#2-analyse-des-services-existants)
  - [3. Création de service](#3-création-de-service)

## Checklist

> Habituez-vous à voir cette petite checklist, elle figurera dans tous les TPs.

A chaque machine déployée, vous **DEVREZ** vérifier la 📝**checklist**📝 :

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] firewall actif, qui ne laisse passer que le strict nécessaire
- [x] SSH fonctionnel
- [x] accès Internet (une route par défaut, une carte NAT c'est très bien)
- [x] résolution de nom
- [x] SELinux en mode *"permissive"* (vérifiez avec `sestatus`, voir [mémo install VM tout en bas](https://gitlab.com/it4lik/b1-reseau-2022/-/blob/main/cours/memo/install_vm.md#4-pr%C3%A9parer-la-vm-au-clonage))

**Les éléments de la 📝checklist📝 sont STRICTEMENT OBLIGATOIRES à réaliser mais ne doivent PAS figurer dans le rendu.**

![Checklist](./pics/checklist_is_here.jpg)

# I. Service SSH

Le service SSH est déjà installé sur la machine, et il est aussi déjà démarré par défaut, c'est Rocky qui fait ça nativement.

## 1. Analyse du service

On va, dans cette première partie, analyser le service SSH qui est en cours d'exécution.

🌞 **S'assurer que le service `sshd` est démarré**

- avec une commande `systemctl status`

[user@vm ~]$ systemctl status
● vm.tp2.linux
    State: running
     Jobs: 0 queued
   Failed: 0 units
    Since: Tue 2022-12-06 09:10:05 CET; 42min ago













🌞 **Analyser les processus liés au service SSH**

- afficher les processus liés au service `sshd`
  - vous pouvez afficher la liste des processus en cours d'exécution avec une commande `ps`
  - pour le compte-rendu, vous devez filtrer la sortie de la commande en ajoutant `| grep <TEXTE_RECHERCHE>` après une commande

[user@vm ~]$ ps -ef | grep sshd
root         688       1  0 09:10 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1205     688  0 09:10 ?        00:00:00 sshd: user [priv]
user        1211    1205  0 09:10 ?        00:00:00 sshd: user@pts/0
user        1310    1212  0 10:04 pts/0    00:00:00 grep --color=auto sshd


🌞 **Déterminer le port sur lequel écoute le service SSH**

- avec une commande `ss`
- isolez les lignes intéressantes avec un `| grep <TEXTE>`

[user@vm ~]$ ss | grep ssh
tcp   ESTAB  0      52                        10.3.2.3:ssh           10.3.2.1:63555

🌞 **Consulter les logs du service SSH**

- les logs du service sont consultables avec une commande `journalctl`
[user@vm log]$ journalctl | grep ssh
Dec 06 09:10:06 vm.tp2.linux systemd[1]: Created slice Slice /system/sshd-keygen.
Dec 06 09:10:06 vm.tp2.linux systemd[1]: Reached target sshd-keygen.target.
Dec 06 09:10:06 vm.tp2.linux sshd[688]: Server listening on 0.0.0.0 port 22.
Dec 06 09:10:06 vm.tp2.linux sshd[688]: Server listening on :: port 22.
Dec 06 09:10:54 vm.tp2.linux sshd[1205]: Accepted password for user from 10.3.2.1 port 63555 ssh2
Dec 06 09:10:54 vm.tp2.linux sshd[1205]: pam_unix(sshd:session): session opened for user user(uid=1000) by (uid=0)
Dec 06 10:02:13 vm.tp2.linux sudo[1296]:     user : TTY=tty1 ; PWD=/home/user ; USER=root ; COMMAND=/sbin/sshd

- un fichier de log qui répertorie toutes les tentatives de connexion SSH existe
  - il est dans le dossier `/var/log`
  - utilisez une commande `tail` pour visualiser les 10 dernière lignes de ce fichier


[user@vm log]$ sudo tail -n 10 secure
[sudo] password for user:
Dec  6 09:10:54 vm sshd[1205]: Accepted password for user from 10.3.2.1 port 63555 ssh2
Dec  6 09:10:54 vm sshd[1205]: pam_unix(sshd:session): session opened for user user(uid=1000) by (uid=0)
Dec  6 10:02:13 vm sudo[1296]:    user : TTY=tty1 ; PWD=/home/user ; USER=root ; COMMAND=/sbin/sshd
Dec  6 10:02:13 vm sudo[1296]: pam_unix(sudo:session): session opened for user root(uid=0) by user(uid=1000)
Dec  6 10:02:13 vm sudo[1296]: pam_unix(sudo:session): session closed for user root
Dec  6 10:19:28 vm unix_chkpwd[1351]: password check failed for user (user)
Dec  6 10:19:28 vm sudo[1349]: pam_unix(sudo:auth): authentication failure; logname=user uid=1000 euid=0 tty=/dev/pts/0 ruser=user rhost=  user=user
Dec  6 10:19:30 vm sudo[1349]: pam_unix(sudo:auth): conversation failed
Dec  6 10:19:30 vm sudo[1349]: pam_unix(sudo:auth): auth could not identify password for [user]
Dec  6 10:19:30 vm sudo[1349]:    user : 1 incorrect password attempt ; TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/tail -n 10 sercure
![When she tells you](./pics/when_she_tells_you.png)

## 2. Modification du service

Dans cette section, on va aller visiter et modifier le fichier de configuration du serveur SSH.

Comme tout fichier de configuration, celui de SSH se trouve dans le dossier `/etc/`.

Plus précisément, il existe un sous-dossier `/etc/ssh/` qui contient toute la configuration relative au protocole SSH

🌞 **Identifier le fichier de configuration du serveur SSH**

[user@vm ssh]$ ls
moduli        sshd_config.d           ssh_host_ed25519_key.pub
ssh_config    ssh_host_ecdsa_key      ssh_host_rsa_key
ssh_config.d  ssh_host_ecdsa_key.pub  ssh_host_rsa_key.pub
sshd_config   ssh_host_ed25519_key

c'est le fichier sshd_config qui fait la configuration du serveur ssh

🌞 **Modifier le fichier de conf**

- exécutez un `echo $RANDOM` pour demander à votre shell de vous fournir un nombre aléatoire
  - simplement pour vous montrer la petite astuce et vous faire manipuler le shell :)
  
 
  [user@vm ssh]$ [user@vm ssh]$ echo $RANDOM
29130

- changez le port d'écoute du serveur SSH pour qu'il écoute sur ce numéro de port
- 
[user@vm ssh]$ sudo nano sshd_config

  - dans le compte-rendu je veux un `cat` du fichier de conf
  - filtré par un `| grep` pour mettre en évidence la ligne que vous avez modifié
  - 
 [user@vm ssh]$ sudo cat sshd_config | grep 29130
Port 29130

- gérer le firewall
  - fermer l'ancien port
  
  [user@vm ssh]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success

  - ouvrir le nouveau port

[user@vm ssh]$ sudo firewall-cmd --add-port=29130/tcp --permanent
success

  - vérifier avec un `firewall-cmd --list-all` que le port est bien ouvert
    - vous filtrerez la sortie de la commande avec un `| grep TEXTE`

[user@vm ssh]$ sudo firewall-cmd --list-all | grep ports
  ports: 29130/tcp
  forward-ports:
  source-ports:

🌞 **Redémarrer le service**

- avec une commande `systemctl restart`

[user@vm ssh]$ sudo systemctl reboot

🌞 **Effectuer une connexion SSH sur le nouveau port**

- depuis votre PC
- il faudra utiliser une option à la commande `ssh` pour vous connecter à la VM

PS C:\Users\titim> ssh -p 29130 user@10.3.2.3
user@10.3.2.3's password:
Last login: Tue Dec  6 11:29:19 2022
[user@vm ~]$

> Je vous conseille de remettre le port par défaut une fois que cette partie est terminée.

✨ **Bonus : affiner la conf du serveur SSH**

- faites vos plus belles recherches internet pour améliorer la conf de SSH
- par "améliorer" on entend essentiellement ici : augmenter son niveau de sécurité
- le but c'est pas de me rendre 10000 lignes de conf que vous pompez sur internet pour le bonus, mais de vous éveiller à divers aspects de SSH, la sécu ou d'autres choses liées

![Such a hacker](./pics/such_a_hacker.png)

# II. Service HTTP

Dans cette partie, on ne va pas se limiter à un service déjà présent sur la machine : on va ajouter un service à la machine.

On va faire dans le *clasico* et installer un serveur HTTP très réputé : NGINX.  
Un serveur HTTP permet d'héberger des sites web.

Un serveur HTTP (ou "serveur Web") c'est :

- un programme qui écoute sur un port (ouais ça change pas ça)
- il permet d'héberger des sites web
  - un site web c'est un tas de pages html, js, css
  - un site web c'est aussi parfois du code php, python ou autres, qui indiquent comment le site doit se comporter
- il permet à des clients de visiter les sites web hébergés
  - pour ça, il faut un client HTTP (par exemple, un navigateur web)
  - le client peut alors se connecter au port du serveur (connu à l'avance)
  - une fois le tunnel de communication établi, le client effectuera des requêtes HTTP
  - le serveur répondra à l'aide du protocole HTTP

> Une requête HTTP c'est "donne moi tel fichier HTML". Une réponse c'est "voici tel fichier HTML" + le fichier HTML en question.

Ok bon on y va ?

## 1. Mise en place

![nngijgingingingijijnx ?](./pics/njgjgijigngignx.jpg)

🌞 **Installer le serveur NGINX**

- je vous laisse faire votre recherche internet
- n'oubliez pas de préciser que c'est pour "Rocky 9"

[user@vm ~]$ sudo dnf install nginx

🌞 **Démarrer le service NGINX**

[user@vm ~]$ sudo systemctl start nginx

🌞 **Déterminer sur quel port tourne NGINX**

[user@vm home]$ sudo ss -alnpt | grep nginx
[sudo] password for user:
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=818,fd=6),("nginx",pid=816,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=818,fd=7),("nginx",pid=816,fd=7))

[user@vm home]$ sudo firewall-cmd --add-port=80/tcp
success

🌞 **Déterminer les processus liés à l'exécution de NGINX**

[user@vm home]$ ps -ef | grep nginx
root         816       1  0 11:49 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx        818     816  0 11:49 ?        00:00:00 nginx: worker process
user        1566    1226  0 20:11 pts/0    00:00:00 grep --color=auto nginx

🌞 **Euh wait**

[user@vm ~]$ curl 10.3.2.3:80 | head -7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
  html>
 head>
meta charset='utf-8'>
    meta name='viewport' content='width=device-width, initial-scale=1'>
    title>HTTP Server Test Page powered by: Rocky Linux</title>
    style type="text/css">
100  7620  100  7620    0     0   826k      0 --:--:-- --:--:-- --:--:--  826k
curl: (23) Failed writing body


## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**


    
    [user@vm ~]$ cat /etc/nginx/nginx.conf | grep -m 1 'server {' -A 16
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
[user@vm ~]$ cat /etc/nginx/nginx.conf | grep include
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

[user@vm /]$ sudo mkdir /var/www

[user@vm /]$ sudo mkdir /var/www/tp2_linux

[user@vm /]$ sudo nano /var/www/tp2_linux/index.html

🌞 **Adapter la conf NGINX**

[user@vm nginx]$ echo $RANDOM
9567

[user@vm nginx]$ sudo nano /etc/nginx/conf.d/tp2.conf
server {
 listen 9567;

 root /var/www/tp2_linux;
}


[user@vm nginx]$ sudo systemctl restart nginx

[user@vm nginx]$ sudo firewall-cmd --add-port=9567/tcp --permanent
success

[user@vm nginx]$ sudo firewall-cmd --reload
success


[user@vm nginx]$ sudo firewall-cmd --list-all | grep -m 1 ports
  ports: 22/tcp 9567/tcp
  
🌞 **Visitez votre super site web**

[user@vm nginx]$ curl 10.3.2.3:9567
<h1>MEOW mon premier serveur web</h1>

# III. Your own services

Dans cette partie, on va créer notre propre service :)

HE ! Vous vous souvenez de `netcat` ou `nc` ? Le ptit machin de notre premier cours de réseau ? C'EST L'HEURE DE LE RESORTIR DES PLACARDS.

## 1. Au cas où vous auriez oublié

Au cas où vous auriez oublié, une petite partie qui ne doit pas figurer dans le compte-rendu, pour vous remettre `nc` en main.

> Allez-le télécharger sur votre PC si vous ne l'avez pu. Lien dans Google ou dans le premier TP réseau.

➜ Dans la VM

- `nc -l 8888`
  - lance netcat en mode listen
  - il écoute sur le port 8888
  - sans rien préciser de plus, c'est le port 8888 TCP qui est utilisé

➜ Sur votre PC

- `nc <IP_VM> 8888`
- vérifiez que vous pouvez envoyer des messages dans les deux sens

> Oubliez pas d'ouvrir le port 8888/tcp de la VM bien sûr :)

## 2. Analyse des services existants

Un service c'est quoi concrètement ? C'est juste un processus, que le système lance, et dont il s'occupe après.

Il est défini dans un simple fichier texte, qui contient une info primordiale : la commande exécutée quand on "start" le service.

Il est possible de définir beaucoup d'autres paramètres optionnels afin que notre service s'exécute dans de bonnes conditions.

🌞 **Afficher le fichier de service SSH**

[user@vm nginx]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
    Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
    Active: active (running) since Wed 2022-12-07 13:24:43 CET; 11min ago
      Docs: man:sshd(8)
            man:sshd_config(5)
  Main PID: 683 (sshd)
     Tasks: 1 (limit: 5905)
    Memory: 5.8M
       CPU: 43ms
    CGroup: /system.slice/sshd.service
            └─683 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 07 13:24:43 tp2 systemd[1]: Starting OpenSSH server daemon...
Dec 07 13:24:43 tp2 sshd[683]: Server listening on 0.0.0.0 port 22.
Dec 07 13:24:43 tp2 sshd[683]: Server listening on :: port 22.
Dec 07 13:24:43 tp2 systemd[1]: Started OpenSSH server daemon.
Dec 07 13:25:31 tp2 sshd[868]: Accepted password for user from 10.3.2.3 port 9867 ssh2
Dec 07 13:25:31 tp2 sshd[868]: pam_unix(sshd:session): session opened for user user(uid=1000) by (uid=0

[user@vm nginx]$ sudo cat /usr/lib/systemd/system/sshd.service | grep ExecStart
[sudo] password for user:
ExecStart=/usr/sbin/sshd -D $OPTIONS

🌞 **Afficher le fichier de service NGINX**

[user@vm nginx]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
    Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
    Active: active (running) since Wed 2022-12-07 13:24:43 CET; 18min ago
   Process: 806 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
   Process: 807 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
   Process: 813 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Main PID: 814 (nginx)
     Tasks: 2 (limit: 5905)
    Memory: 3.7M
       CPU: 12ms
    CGroup: /system.slice/nginx.service
            ├─814 "nginx: master process /usr/sbin/nginx"
            └─819 "nginx: worker process"

Dec 07 13:24:43 tp2 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Dec 07 13:24:43 tp2 nginx[807]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Dec 07 13:24:43 tp2 nginx[807]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Dec 07 13:24:43 tp2 systemd[1]: Started The nginx HTTP and reverse proxy server.

[user@vm nginx]$ sudo cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
## 3. Création de service

![Create service](./pics/create_service.png)

Bon ! On va créer un petit service qui lance un `nc`. Et vous allez tout de suite voir pourquoi c'est pratique d'en faire un service et pas juste le lancer à la min.

Ca reste un truc pour s'exercer, c'pas non plus le truc le plus utile de l'année que de mettre un `nc` dans un service n_n

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

[user@vm nginx]]$ echo $RANDOM
9567

[user@vm nginx]$ sudo nano /etc/systemd/system/tp2_nc.service

[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l <9567>

[user@vm nginx]$ sudo firewall-cmd --add-port=9567/tcp --permanent
success
[user@vm nginx]$ sudo firewall-cmd --reload
success
[user@vm nginx]$ sudo firewall-cmd --list-all | grep 9567
 ports: 22/tcp 24015/tcp 8888/tcp 9567/tcp
 
 [Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l <PORT>

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

[user@vm nginx]$ sudo systemctl daemon-reload

🌞 **Démarrer notre service de ouf**

[user@vm nginx]$ sudo systemctl start tp2_nc

🌞 **Vérifier que ça fonctionne**

[user@vm nginx]$ sudo systemctl status tp2_nc
● tp2_nc.service - Super netcat tout fou
    Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
    Active: active (running) since Wed 2022-12-07 13:59:41 CET; 10s ago
  Main PID: 1142 (nc)
     Tasks: 1 (limit: 5905)
    Memory: 780.0K
       CPU: 1ms
    CGroup: /system.slice/tp2_nc.service
            └─1142 /usr/bin/nc -l 9567

Dec 07 13:59:41 tp2 systemd[1]: Started Super netcat tout fou.

[user@vm nginx]$ sudo ss -alnpt | grep 9567
LISTEN 0      10           0.0.0.0:9567      0.0.0.0:*    users:(("nc",pid=1142,fd=4))
LISTEN 0      10              [::]:9567        [::]:*    users:(("nc",pid=1142,fd=3))

[user@vm nginx]$ nc 10.3.1.10 9567
hola
hey

🌞 **Les logs de votre service**

[user@vm nginx]$ sudo journalctl -xe -u tp2_nc | grep start
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.

[user@vm nginx]$ sudo journalctl -xe -u tp2_nc | grep "oui"
Dec 07 18:54:58 tp2 nc[934]: oui

[user@vm nginx]$  sudo journalctl -xe -u tp2_nc | grep stop
░░ Subject: A stop job for unit tp2_nc.service has begun execution
░░ A stop job for unit tp2_nc.service has begun execution.
🌞 **Affiner la définition du service**

[user@vm nginx]$  cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 9567
Restart=always