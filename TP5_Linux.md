# Partie 1 : Mise en place et maîtrise du serveur Web

Dans cette partie on va installer le serveur web, et prendre un peu la maîtrise dessus, en regardant où il stocke sa conf, ses logs, etc. Et en manipulant un peu tout ça bien sûr.

On va installer un serveur Web très très trèèès utilisé autour du monde : le serveur Web Apache.

- [Partie 1 : Mise en place et maîtrise du serveur Web](#partie-1--mise-en-place-et-maîtrise-du-serveur-web)
  - [1. Installation](#1-installation)
  - [2. Avancer vers la maîtrise du service](#2-avancer-vers-la-maîtrise-du-service)

![Tipiii](../pics/linux_is_a_tipi.jpg)

## 1. Installation

🖥️ **VM web.tp5.linux**

**N'oubliez pas de dérouler la [📝**checklist**📝](../README.md#checklist).**

| Machine         | IP            | Service     |
|-----------------|---------------|-------------|
| `web.tp5.linux` | `10.105.1.11` | Serveur Web |

🌞 **Installer le serveur Apache**

[user@web httpd]$ sudo service httpd start
Redirecting to /bin/systemctl start httpd.service



- paquet `httpd`
- la conf se trouve dans `/etc/httpd/`
 [user@web /]$ cd etc/httpd/conf
[user@web conf]$ ls
httpd.conf  magic

  - le fichier de conf principal est `/etc/httpd/conf/httpd.conf`
  - je vous conseille **vivement** de virer tous les commentaire du fichier, à défaut de les lire, vous y verrez plus clair
    - avec `vim` vous pouvez tout virer avec `:g/^ *#.*/d`

> Ce que j'entends au-dessus par "fichier de conf principal" c'est que c'est **LE SEUL** fichier de conf lu par Apache quand il démarre. C'est souvent comme ça : un service ne lit qu'un unique fichier de conf pour démarrer. Cherchez pas, on va toujours au plus simple. Un seul fichier, c'est simple.  
**En revanche** ce serait le bordel si on mettait toute la conf dans un seul fichier pour pas mal de services.  
Donc, le principe, c'est que ce "fichier de conf principal" définit généralement deux choses. D'une part la conf globale. D'autre part, il inclut d'autres fichiers de confs plus spécifiques.  
On a le meilleur des deux mondes : simplicité (un seul fichier lu au démarrage) et la propreté (éclater la conf dans plusieurs fichiers).

🌞 **Démarrer le service Apache**

- le service s'appelle `httpd` (raccourci pour `httpd.service` en réalité)
  - démarrez-le
  - faites en sorte qu'Apache démarre automatiquement au démarrage de la machine
  [user@web httpd]$ sudo systemctl status httpd.service
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-03 15:55:26 CET; 25s ago
       Docs: man:httpd.service(8)
   Main PID: 1361 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 213 (limit: 11118)
     Memory: 22.7M
        CPU: 53ms
     CGroup: /system.slice/httpd.service
             ├─1361 /usr/sbin/httpd -DFOREGROUND
             ├─1362 /usr/sbin/httpd -DFOREGROUND
             ├─1363 /usr/sbin/httpd -DFOREGROUND
             ├─1364 /usr/sbin/httpd -DFOREGROUND
             └─1365 /usr/sbin/httpd -DFOREGROUND

Jan 03 15:55:26 web.tp5.linux systemd[1]: Starting The Apache HTTP Server...
Jan 03 15:55:26 web.tp5.linux systemd[1]: Started The Apache HTTP Server.
Jan 03 15:55:26 web.tp5.linux httpd[1361]: Server configured, listening on: port 80
    - ça se fait avec une commande `systemctl` référez-vous au mémo
    [user@web conf]$ sudo systemctl enable httpd
    [sudo] password for user:
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
  - ouvrez le port firewall nécessaire
    - utiliser une commande `ss` pour savoir sur quel port tourne actuellement Apache
    - une portion du mémo commandes est dédiée à `ss`
    [user@web conf]$ sudo ss -alnpt
[sudo] password for user:
State      Recv-Q     Send-Q         Local Address:Port         Peer Address:Port    Process
LISTEN     0          128                  0.0.0.0:22                0.0.0.0:*        users:(("sshd",pid=690,fd=3))
LISTEN     0          128                     [::]:22                   [::]:*        users:(("sshd",pid=690,fd=4))
LISTEN     0          511                        *:80                      *:*        users:(("httpd",pid=1365,fd=4),("httpd",pid=1364,fd=4),("httpd",pid=1363,fd=4),("httpd",pid=1361,fd=4))

**En cas de problème** (IN CASE OF FIIIIRE) vous pouvez check les logs d'Apache :

```bash
# Demander à systemd les logs relatifs au service httpd
$ sudo journalctl -xe -u httpd

# Consulter le fichier de logs d'erreur d'Apache
$ sudo cat /var/log/httpd/error_log

# Il existe aussi un fichier de log qui enregistre toutes les requêtes effectuées sur votre serveur
$ sudo cat /var/log/httpd/access_log
```

🌞 **TEST**

- vérifier que le service est démarré
[user@web httpd]$ sudo systemctl status httpd.service
● httpd.service - The Apache HTTP Server
Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
Active: active (running) since Tue 2023-01-03 15:55:26 CET; 25s ago
Docs: man:httpd.service(8)
Main PID: 1361 (httpd)
Status: “Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec: 0 B/sec”
Tasks: 213 (limit: 11118)
Memory: 22.7M
CPU: 53ms
CGroup: /system.slice/httpd.service
├─1361 /usr/sbin/httpd -DFOREGROUND
├─1362 /usr/sbin/httpd -DFOREGROUND
├─1363 /usr/sbin/httpd -DFOREGROUND
├─1364 /usr/sbin/httpd -DFOREGROUND
└─1365 /usr/sbin/httpd -DFOREGROUND
Jan 03 15:55:26 web.tp5.linux systemd[1]: Starting The Apache HTTP Server…
Jan 03 15:55:26 web.tp5.linux systemd[1]: Started The Apache HTTP Server.
Jan 03 15:55:26 web.tp5.linux httpd[1361]: Server configured, listening on: port 80
- vérifier qu'il est configuré pour démarrer automatiquement
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.

- vérifier avec une commande `curl localhost` que vous joignez votre serveur web localement

[user@web conf]$ curl localhost | grep apache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   744k      0 --:--:-- --:--:-- --:--:--  744k
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
      
- vérifier depuis votre PC que vous accéder à la page par défaut
  - avec votre navigateur (sur votre PC)
  - avec une commande `curl` depuis un terminal de votre PC (je veux ça dans le compte-rendu, pas de screen)

PS C:\Users\titim> curl http://10.105.1.11:80/
curl : HTTP Server Test Page
This page is used to test the proper operation of an HTTP server after it has been installed on a Rocky Linux system.
If you can read this page, it means that the software is working correctly.
Just visiting?
This website you are visiting is either experiencing problems or could be going through maintenance.
If you would like the let the administrators of this website know that you've seen this page instead of the page
you've expected, you should send them an email. In general, mail sent to the name "webmaster" and directed to the
website's domain should reach the appropriate person.
The most common email address to send to is: "webmaster@example.com"
Note:
The Rocky Linux distribution is a stable and reproduceable platform based on the sources of Red Hat Enterprise Linux
(RHEL). With this in mind, please understand that:
Neither the Rocky Linux Project nor the Rocky Enterprise Software Foundation have anything to do with this website or
its content.
The Rocky Linux Project nor the RESF have "hacked" this webserver: This test page is included with the distribution.
For more information about Rocky Linux, please visit the Rocky Linux website.
I am the admin, what do I do?
You may now add content to the webroot directory for your software.
For systems using the Apache Webserver: You can add content to the directory /var/www/html/. Until you do so, people
visiting your website will see this page. If you would like this page to not be shown, follow the instructions in:
/etc/httpd/conf.d/welcome.conf.
For systems using Nginx: You can add your content in a location of your choice and edit the root configuration
directive in /etc/nginx/nginx.conf.

Apache™ is a registered trademark of the Apache Software Foundation in the United States and/or other countries.
NGINX™ is a registered trademark of F5 Networks, Inc..
Au caractère Ligne:1 : 1
+ curl http://10.105.1.11:80/
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation : (System.Net.HttpWebRequest:HttpWebRequest) [Invoke-WebRequest], WebEx
   ception
    + FullyQualifiedErrorId : WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

- affichez le contenu du fichier `httpd.service` qui contient la définition du service Apache

[user@web conf]$ sudo nano httpd.conf
 This is the main Apache HTTP server configuration file.  It contains the
 configuration directives that give the server its instructions.
 See <URL:http://httpd.apache.org/docs/2.4/> for detailed information.

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

- mettez en évidence la ligne dans le fichier de conf principal d'Apache (`httpd.conf`) qui définit quel user est utilisé

 User/Group: The name (or #number) of the user/group to run httpd as.
 It is usually good practice to create a dedicated user and group for
 running httpd, as with most system services.

User apache
Group apache

- utilisez la commande `ps -ef` pour visualiser les processus en cours d'exécution et confirmer que apache tourne bien sous l'utilisateur mentionné dans le fichier de conf

[user@web conf]$ ps -ef | grep apache
apache      1362    1361  0 15:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1363    1361  0 15:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1364    1361  0 15:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1365    1361  0 15:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1691    1361  0 16:43 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
user        1778    1213  0 16:53 pts/0    00:00:00 grep --color=auto apache
 
- la page d'accueil d'Apache se trouve dans `/usr/share/testpage/`
  - vérifiez avec un `ls -al` que tout son contenu est **accessible en lecture** à l'utilisateur mentionné dans le fichier de conf
[user@web conf]$ ls -al | grep httpd.conf
-rw-r--r--. 1 root root 12005 Nov 16 08:08 httpd.conf

🌞 **Changer l'utilisateur utilisé par Apache**

- créez un nouvel utilisateur
  - pour les options de création, inspirez-vous de l'utilisateur Apache existant
  
  user@web etc]$ sudo useradd tp5-apache -d /usr/share/httpd/ -s /sbin/nologin
[sudo] password for user:
Sorry, try again.
[sudo] password for user:
useradd: warning: the home directory /usr/share/httpd/ already exists.
useradd: Not copying any file from skel directory into it.


    - le fichier `/etc/passwd` contient les informations relatives aux utilisateurs existants sur la machine
    - servez-vous en pour voir la config actuelle de l'utilisateur Apache par défaut (son homedir et son shell en particulier)
- modifiez la configuration d'Apache pour qu'il utilise ce nouvel utilisateur

[user@web etc]$ sudo nano /etc/httpd/conf/httpd.conf

  - montrez la ligne de conf dans le compte rendu, avec un `grep` pour ne montrer que la ligne importante

[user@web etc]$ sudo cat /etc/httpd/conf/httpd.conf | grep ^User
User tp5-apache

- redémarrez Apache
- utilisez une commande `ps` pour vérifier que le changement a pris effet


[user@web etc]$ sudo service httpd restart
[sudo] password for user:
Redirecting to /bin/systemctl restart httpd.service

  - vous devriez voir un processus au moins qui tourne sous l'identité de votre nouvel utilisateur
  
  [user@web etc]$ ps aux | grep -i tp-5
user        2075  0.0  0.1   6412  2264 pts/0    S+   17:23   0:00 grep --color=auto -i tp-5

🌞 **Faites en sorte que Apache tourne sur un autre port**

- modifiez la configuration d'Apache pour lui demander d'écouter sur un autre port de votre choix

[user@web etc]$ sudo nano /etc/httpd/conf/httpd.conf

  - montrez la ligne de conf dans le compte rendu, avec un `grep` pour ne montrer que la ligne importante
  [user@web conf]$ cat httpd.conf | grep Listen
 Listen: Allows you to bind Apache to specific IP addresses and/or
 Change this to Listen on a specific IP address, but note that if
#Listen 12.34.56.78:80
Listen 1800
- ouvrez ce nouveau port dans le firewall, et fermez l'ancien
 [user@web conf]$ sudo firewall-cmd --add-port=1800/tcp --permanent
[sudo] password for user:
success
[user@web conf]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[user@web conf]$
- redémarrez Apache
 [user@web conf]$ sudo service httpd restart
Redirecting to /bin/systemctl restart httpd.service
- prouvez avec une commande `ss` que Apache tourne bien sur le nouveau port choisi
[user@web ~]$ sudo ss -alnpt
[sudo] password for user:
State      Recv-Q     Send-Q         Local Address:Port         Peer Address:Port    Process
LISTEN     0          128                  0.0.0.0:22                0.0.0.0:*        users:(("sshd",pid=696,fd=3))
LISTEN     0          128                     [::]:22                   [::]:*        users:(("sshd",pid=696,fd=4))
LISTEN     0          511                        *:1800                    *:*        users:(("httpd",pid=724,fd=4)
- vérifiez avec `curl` en local que vous pouvez joindre Apache sur le nouveau port
- vérifiez avec votre navigateur que vous pouvez joindre le serveur sur le nouveau port



[user@web ~]$ curl http://10.105.1.11:1800/
<!doctype html>
html>
  head>
    meta charset='utf-8'>
    meta name='viewport' content='width=device-width, initial-scale=1'>
title>HTTP Server Test Page powered by: Rocky Linux</title>
    style type="text/css">
      /*<![CDATA[*/
        
        
        

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

➜ **Si c'est tout bon vous pouvez passer à [la partie 2.](../part2/README.md)**

# Partie 2 : Mise en place et maîtrise du serveur de base de données

Petite section de mise en place du serveur de base de données sur `db.tp5.linux`. On ira pas aussi loin qu'Apache pour lui, simplement l'installer, faire une configuration élémentaire avec une commande guidée (`mysql_secure_installation`), et l'analyser un peu.

🖥️ **VM db.tp5.linux**

**N'oubliez pas de dérouler la [📝**checklist**📝](#checklist).**

| Machines        | IP            | Service                 |
|-----------------|---------------|-------------------------|
| `web.tp5.linux` | `10.105.1.11` | Serveur Web             |
| `db.tp5.linux`  | `10.105.1.12` | Serveur Base de Données |

🌞 **Install de MariaDB sur `db.tp5.linux`**

[user@vm /]$ sudo dnf install mariadb-server
Rocky Linux 9 - BaseOS                                                                  7.5 kB/s | 3.6 kB     00:00
Rocky Linux 9 - BaseOS                                                                  749 kB/s | 1.7 MB     00:02
Rocky Linux 9 - AppStream                                                                11 kB/s | 4.1 kB     00:00
Rocky Linux 9 - AppStream                                                               802 kB/s | 6.4 MB     00:08
Rocky Linux 9 - Extras                                                                  7.3 kB/s | 2.9 kB     00:00
Dependencies resolved.

[user@vm /]$ sudo systemctl start mariadb

[user@vm /]$ sudo systemctl enable mariadb


🌞 **Port utilisé par MariaDB**

- vous repérerez le port utilisé par MariaDB avec une commande `ss` exécutée sur `db.tp5.linux`
  - filtrez les infos importantes avec un `| grep`
- il sera nécessaire de l'ouvrir dans le firewall
[user@vm /]$ sudo ss -tulpn | grep LISTEN
tcp   LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=4242,fd=19))

[user@vm /]$ sudo firewall-cmd --add-port=3306/tcp --permanent
[user@vm /]$ sudo firewall-cmd --reload

> La doc vous fait exécuter la commande `mysql_secure_installation` c'est un bon réflexe pour renforcer la base qui a une configuration un peu *chillax* à l'install.

🌞 **Processus liés à MariaDB**

- repérez les processus lancés lorsque vous lancez le service MariaDB
- utilisz une commande `ps`
  - filtrez les infos importantes avec un `| grep`
[user@vm /]$ ps -ef | grep maria
mysql       4242       1  0 10:19 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
user        4445    1211  0 10:48 pts/0    00:00:00 grep --color=auto maria

➜ **Une fois la db en place, go sur [la partie 3.](../part3/README.md)**

# h1Partie 3 : Configuration et mise en place de NextCloud
## h2Partie 3 : Configuration et mise en place de NextCloud
1. Base de données
2. Serveur Web et NextCloud
3. Finaliser l'installation de NextCloud
## h2🌞 Préparation de la base pour NextCloud

[user@db ~]$ sudo mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 13
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
[user@db ~]$ sudo mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 13
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';

    -> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

    -> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';

    -> FLUSH PRIVILEGES;
## h2🌞 Exploration de la base de données

[user@web ~]$ sudo dnf install mysql
[user@web ~]$ mysql -u nextcloud -h 10.105.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud;
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)
## h2🌞 Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données

[user@db ~]$ sudo mysql -u root -p
[sudo] password for orealyz:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 5
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> use mysql;SELECT user FROM user;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.000 sec)               
2. Serveur Web et NextCloud
[user@web conf]$ sudo firewall-cmd --add-port=80/tcp --permament
usage: see firewall-cmd man page
firewall-cmd: error: unrecognized arguments: --permament
[user@web conf]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user@web conf]$ sudo firewall-cmd --remove-port=1918/tcp --permanent
success
[user@web conf]$ sudo firewall-cmd --reload
success
🌞 Install de PHP

[user@web conf]$ sudo dnf config-manager --set-enabled crb
[user@web conf]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
[user@web conf]$ dnf module list php
[user@web conf]$ sudo dnf module enable php:remi-8.1 -y
[user@web conf]$ sudo dnf install -y php81-php
🌞 Install de tous les modules PHP nécessaires pour NextCloud

[user@web conf]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
🌞 Récupérer NextCloud

[user@web conf]$ sudo mkdir /var/www/tp5_nextcloud/
[user@web conf]$ sudo dnf install wget -y
[user@web tp5_nextcloud]$ sudo dnf install unzip
[user@web tp5_nextcloud]$ sudo wget https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
[user@web tp5_nextcloud]$ sudo unzip nextcloud-25.0.0rc3.zip
[user@web tp5_nextcloud]$ cd nextcloud
[user@web tp5_nextcloud]$ sudo chown apache *
🌞 Adapter la configuration d'Apache

[user@web conf.d]$ sudo cat nextcloud.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>```


🌞 Redémarrer le service Apache pour qu'il prenne en compte le nouveau fichier de conf

[orealyz@web conf.d]$ sudo systemctl restart httpd