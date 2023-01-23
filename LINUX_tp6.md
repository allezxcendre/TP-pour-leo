# Module 1 : Reverse Proxy


## Sommaire

- [Module 1 : Reverse Proxy](#module-1--reverse-proxy)
  - [Sommaire](#sommaire)
- [I. Setup](#i-setup)
- [II. HTTPS](#ii-https)

# I. Setup

🌞 **On utilisera NGINX comme reverse proxy**

```
[user@proxy ~]$ sudo dnf install nginx
```
```
[user@proxy ~]$ sudo systemctl start nginx
[user@proxy ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 12:08:44 CET; 10s ago
    Process: 1116 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1117 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1118 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1119 (nginx)
      Tasks: 2 (limit: 5905)
     Memory: 1.9M
        CPU: 13ms
     CGroup: /system.slice/nginx.service
             ├─1119 "nginx: master process /usr/sbin/nginx"
             └─1120 "nginx: worker process"

Jan 16 12:08:44 proxy.tp6.linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 12:08:44 proxy.tp6.linux nginx[1117]: nginx: the configuration file /etc/nginx/nginx.conf synt>
Jan 16 12:08:44 proxy.tp6.linux nginx[1117]: nginx: configuration file /etc/nginx/nginx.conf test is >
Jan 16 12:08:44 proxy.tp6.linux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
```
[user@proxy ~]$ sudo ss -tulpn | grep nginx
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1120,fd=6),("ngin
",pid=1119,fd=6))
tcp   LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1120,fd=7),("ngin
",pid=1119,fd=7))
```
```
[user@proxy ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user@proxy ~]$ sudo firewall-cmd --reload
success
[user@proxy ~]$ sudo firewall-cmd --list-all | grep port
  ports: 80/tcp
  forward-ports:
  source-ports:
```
```
[user@proxy ~]$ sudo ps -ef | grep nginx
root        1119       1  0 12:08 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1120    1119  0 12:08 ?        00:00:00 nginx: worker process
user     1155     933  0 12:11 pts/0    00:00:00 grep --color=auto nginx
```
```
[user@proxy ~]$ curl http://10.105.1.3:80 | head -10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
100  7620  100  7620    0     0  1063k      0 --:--:-- --:--:-- --:--:-- 1063k
curl: (23) Failed writing body
```
🌞 **Configurer NGINX**
```
[user@proxy nginx]$ sudo cat nginx.conf | grep conf
    include /etc/nginx/conf.d/*.conf;
```
```
[user@web ~]$ sudo cat /var/www/tp5_nextcloud/config/config.php | grep 1
    1 => '10.105.1.3'
```
```
[user@proxy conf.d]$ sudo nano proxy_tp6.conf
[sudo] password for user:
[user@proxy conf.d]$ sudo cat proxy_tp6.conf
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name www.nextcloud.tp6;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://<IP_DE_NEXTCLOUD>:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```


➜ **Modifier votre fichier `hosts` de VOTRE PC**

🌞 **Faites en sorte de**

- rendre le serveur `web.tp6.linux` injoignable
- sauf depuis l'IP du reverse proxy
- en effet, les clients ne doivent pas joindre en direct le serveur web : notre reverse proxy est là pour servir de serveur frontal
- **comment ?** Je vous laisser là encore chercher un peu par vous-mêmes (hint : firewall)
```
[user@web ~]$ sudo firewall-cmd --remove-interface enp0s8 --zone=public --permanent
The interface is under control of NetworkManager and already bound to the default zone
The interface is under control of NetworkManager, setting zone to default.
success
[user@web ~]$ sudo firewall-cmd --add-interface enp0s8 --zone=trusted --permanent
The interface is under control of NetworkManager, setting zone to 'trusted'.
success
[user@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 80/tcp 19999/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[user@web ~]$ sudo firewall-cmd --add-port=22/tcp --permanent --zone=trusted
success
[user@web ~]$ sudo firewall-cmd --add-source=10.105.1.1 --permanent --zone=trusted
success
[user@web ~]$ sudo firewall-cmd --permanent --zone=trusted --set-target=DROP
success
[user@web ~]$ sudo firewall-cmd --set-default-zone trusted
success
[user@web ~]$ sudo firewall-cmd --reload
success
[user@web ~]$ sudo firewall-cmd --list-all
trusted (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 10.105.1.1
  services:
  ports: 22/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

🌞 **Une fois que c'est en place**

```
PS C:\Users\b> ping 10.105.1.3

Envoi d’une requête 'Ping'  10.105.1.3 avec 32 octets de données :
Réponse de 10.105.1.3 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.3 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.3 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.3 : octets=32 temps<1ms TTL=64

Statistiques Ping pour 10.105.1.3:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
```
```
PS C:\Users\b> ping 10.105.1.11

Envoi d’une requête 'Ping'  10.105.1.11 avec 32 octets de données :
Délai d’attente de la demande dépassé.

Statistiques Ping pour 10.105.1.11:
    Paquets : envoyés = 1, reçus = 0, perdus = 1 (perte 100%),
```

# II. HTTPS

🌞 **Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP**
```
[user@web ~]$ openssl genrsa -aes128 2048 > server.key 
[user@web ~]$ openssl rsa -in server.key -out server.key 
[user@web ~]$ openssl req -utf8 -new -key server.key -out server.csr
[user@web ~]$ openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 3650 
[user@web ~]$ chmod 600 server.key
```
```
[user@web ~]$ cat /etc/nginx/conf.d/nginx.conf 
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name www.nextcloud.tp6;

    # Port d'écoute de NGINX
    listen 443 ssl;
    server_name example.yourdomain.com;
    ssl_certificate  /home/user/server.crt;
    ssl_certificate_key  /home/user/server.key; 
    ssl_prefer_server_ciphers on;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying 
        proxy_pass http://10.105.1.11:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```

```
[user@web ~]$ sudo systemctl restart nginx
[user@web ~]$ sudo firewall-cmd --add-port=443/tcp --permanent
success
[user@web ~]$ sudo firewall-cmd --reload
success
[user@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[user@web ~]$ sudo firewall-cmd --reload
success
```

```
[user@web ~]$ curl https://www.nextcloud.tp6
curl: (60) SSL certificate problem: self-signed certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

Module 2 : Sauvegarde du système de fichiers
Sommaire
Module 2 : Sauvegarde du système de fichiers
Sommaire
I. Script de backup
1. Ecriture du script
2. Clean it
3. Service et timer
II. NFS
1. Serveur NFS
2. Client NFS
I. Script de backup
1. Ecriture du script
➜ Commentez le script

[user@web srv]$ sudo cat tp6_backup.sh
[sudo] password for user:
#!/bin/bash

#Date
date=`date +"%y%m%d%H%M%S"`
#Nom du fichier
filename=nextcloud-backup_$date.zip
#Archive du mode maintenance de nextcloud
sed -i "s/'maintenance' => false,/'maintenance' => true,/" /var/www/tp5_nextcloud/config/config.php
#Archive le dossier nextcloud
cd /srv/backup
zip -r $filename /var/www/tp5_nextcloud > /dev/null
#Désactive le mode maintenance de nextcloud
sed -i "s/'maintenance' => true,/'maintenance' => false,/" /var/www/tp5_nextcloud/config/config.php

echo "Zip folder available /srv/backup/$filename"


#Script réalisé par Alexandre Milanese, le 17/01/2023
#Le script va permettre une sauvegarde de toutes les données de nextcloud permettant de récupérer les données en cas de perte.
#On va donc activer le mode de maintenance sur nextcloud, l'archiver et ensuite désactiver le mode de maintenance
➜ Environnement d'exécution du script

[user@web srv]$ sudo useradd -m -d /srv/backup/ -s /usr/sbin/nologin backup
[user@web srv]$ sudo -u backup /srv/tp6_backup.sh
3. Service et timer
🌞 Créez un service système qui lance le script

[user@web system]$ sudo cat backup.service
[Unit]
Description=Ce petit service permet de faire des backup du dossier nextcloud

[Service]
Type=oneshot
ExecStart=/srv/tp6_backup.sh
User=backup
🌞 Créez un timer système qui lance le service à intervalles réguliers

[Unit]
Description=Run service X

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
🌞 Activez l'utilisation du timer

[user@web ~]$ cat /etc/systemd/system/backup.timer
[Unit]
Description=Run backup service

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
[user@web ~]$ sudo systemctl list-timers
NEXT                        LEFT         LAST                        PASSED       UNIT              >
Fri 2023-01-06 16:00:30 CET 1h 5min left Fri 2023-01-06 14:21:17 CET 34min ago    dnf-makecache.time>
Sat 2023-01-07 00:00:00 CET 9h left      Fri 2023-01-06 13:45:04 CET 1h 10min ago logrotate.timer   >
Sat 2023-01-07 04:00:00 CET 13h left     n/a                         n/a          backup.timer      >
Sat 2023-01-07 14:00:07 CET 23h left     Fri 2023-01-06 14:00:07 CET 55min ago    systemd-tmpfiles-c>

4 timers listed.
Pass --all to see loaded but inactive timers, too.
II. NFS
1. Serveur NFS
🖥️ VM storage.tp6.linux

🌞 Préparer un dossier à partager sur le réseau (sur la machine storage.tp6.linux)

[user@web ~]$ sudo mkdir -p /srv/nfs_shares/web.tp6.linux/
🌞 Installer le serveur NFS (sur la machine storage.tp6.linux)

[user@web ~]$ sudo dnf install nfs-utils -y
[user@web ~]$ sudo systemctl enable nfs-server
[user@web ~]$ sudo systemctl start nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[user@web ~]$ sudo systemctl start nfs-server
[user@web ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[user@web ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[user@web ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[user@web ~]$ sudo firewall-cmd --reload
success
[user@web ~]$ cat /etc/exports
/srv/nfs_shares/web.tp6.linux/	10.105.1.11(rw,sync,no_root_squash,insecure)
2. Client NFS
🌞 Installer un client NFS sur web.tp6.linux

[user@web ~]$ sudo dnf install nfs-utils -y
[user@web ~]$ sudo firewall-cmd --permanent --zone=home --add-source=10.105.1.20
success
[user@web ~]$ sudo firewall-cmd --reload
[user@web ~]$ sudo mount 10.105.1.20:/srv/nfs_shares/web.tp6.linux/ /srv/backup/
[user@web ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Sat Oct 15 12:47:23 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=2df805a9-4569-4da4-8afe-e3ee298680df /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0

10.105.1.20:/srv/nfs_shares/web.tp6.linux/ /srv/backup/ ext4 defaults 0 0
🌞 Tester la restauration des données sinon ça sert à rien :)

Module 3 : Fail2Ban
🌞 Faites en sorte que :

[user@db ~]$ sudo systemctl start firewalld
[user@db ~]$ sudo systemctl enable firewalld
[user@db ~]$ sudo systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled>
     Active: active (running) since Mon 2023-01-16 10:14:58 CET; 3min 9>
       Docs: man:firewalld(1)
   Main PID: 644 (firewalld)
      Tasks: 2 (limit: 5905)
     Memory: 41.8M
        CPU: 287ms
     CGroup: /system.slice/firewalld.service
             └─644 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --n>
sudo firewall-cmsudo firewall-cmd --list-all
[user@db ~]$  sudo dnf install epel-release
[user@db ~]$  sudo dnf install fail2ban fail2ban-firewalld
user[user@db ~]$ sudo systemctl enable fail2ban
Created symlink /etc/systemd/system/multi-user.target.wants/fail2ban.service → /usr/lib/systemd/system/fail2ban.service.
[user@db ~]$ sudo systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled;>
     Active: active (running) since Mon 2023-01-16 10:21:38 CET; 8s ago
       Docs: man:fail2ban(1)
   Main PID: 12342 (fail2ban-server)
      Tasks: 3 (limit: 5905)
     Memory: 10.3M
        CPU: 58ms
     CGroup: /system.slice/fail2ban.service
             └─12342 /usr/bin/python3 -s /usr/bin/fail2ban-server -xf s>

Jan 16 10:21:38 db.tp6.linux systemd[1]: Starting Fail2Ban Service...
Jan 16 10:21:38 db.tp6.linux systemd[1]: Started Fail2Ban Service.
Jan 16 10:21:38 db.tp6.linux fail2ban-server[12342]: 2023-01-16 10:21:3>
Jan 16 10:21:39 db.tp6.linux fail2ban-server[12342]: Server ready
[user@db ~]$ sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
[user@db ~]$ sudo mv /etc/fail2ban/jail.d/00-firewalld.conf /etc/fail2ban/jail.d/00-firewalld.local
sudo systemctl restart fail2ban
[user@db ~]$ sudo cat /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true

# Override the default global configuration
# for specific jail sshd
bantime = 1d
findtime = 1min
maxretry = 3
[user@db ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   10.105.1.11
[user@db ~]$ sudo firewall-cmd --list-all | grep ssh
  services: cockpit dhcpv6-client ssh
        rule family="ipv4" source address="10.105.1.11" port port="ssh" protocol="tcp" reject type="icmp-port-unreachable"
[user@db ~]$ sudo fail2ban-client unban 10.105.1.11
1
[user@db ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 0
   |- Total banned:     1
   `- Banned IP list:
   
   # Module 4 : Monitoring

🌞 **Installer Netdata**

```
[user@db ~]$ sudo dnf install epel-release -y
[sudo] password for user:
Last metadata expiration check: 0:07:15 ago on Mon 16 Jan 2023 10:54:36 AM CET.
Package epel-release-9-4.el9.noarch is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```
```
[user@db ~]$ wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh
```
```
[user@db ~]$ sudo systemctl start netdata
[user@db ~]$ sudo systemctl enable netdata
[user@db ~]$ sudo systemctl status netdata
● netdata.service - Real time performance monitoring
     Loaded: loaded (/usr/lib/systemd/system/netdata.service; enabled; >
     Active: active (running) since Mon 2023-01-16 11:04:05 CET; 34s ago
   Main PID: 13143 (netdata)
      Tasks: 76 (limit: 5905)
     Memory: 125.4M
        CPU: 1.676s
     CGroup: /system.slice/netdata.service
             ├─13143 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
             ├─13146 /usr/sbin/netdata --special-spawn-server
             ├─13349 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.>
             ├─13362 /usr/libexec/netdata/plugins.d/apps.plugin 1
             ├─13364 /usr/libexec/netdata/plugins.d/ebpf.plugin 1
             └─13365 /usr/libexec/netdata/plugins.d/go.d.plugin 1
```
```
[user@db ~]$ sudo firewall-cmd --permanent --add-port=19999/tcp
success
[user@db ~]$ sudo firewall-cmd --reload
success
[user@db ~]$ sudo firewall-cmd --list-all | grep port
  ports: 19999/tcp
  forward-ports:
  source-ports:
```
```
[user@web ~]$ sudo ss -ltunp | grep netdata
udp   UNCONN 0      0          127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=1661,fd=39))

udp   UNCONN 0      0              [::1]:8125          [::]:*    users:(("netdata",pid=1661,fd=38))

tcp   LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=1661,fd=41))

tcp   LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=1661,fd=6))

tcp   LISTEN 0      4096           [::1]:8125          [::]:*    users:(("netdata",pid=1661,fd=40))

tcp   LISTEN 0      4096            [::]:19999         [::]:*    users:(("netdata",pid=1661,fd=7))
```

🌞 **Une fois Netdata installé et fonctionnel, déterminer :**


```
[user@web ~]$ ps -aux | grep netdata
netdata     1661  0.5  6.1 463936 48348 ?        SNsl 11:14   0:02 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
netdata     1663  0.0  1.2  28736 10176 ?        SNl  11:14   0:00 /usr/sbin/netdata --special-spawn-server
netdata     1873  0.0  0.4   4504  3500 ?        SN   11:14   0:00 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
netdata     1886  0.4  0.7 134424  6080 ?        SNl  11:14   0:01 /usr/libexec/netdata/plugins.d/apps.plugin 1
root        1887  0.1  4.0 740992 31372 ?        SNl  11:14   0:00 /usr/libexec/netdata/plugins.d/ebpf.plugin 1
netdata     1888  0.1  6.3 773668 49968 ?        SNl  11:14   0:00 /usr/libexec/netdata/plugins.d/go.d.plugin 1
user     2287  0.0  0.2   6408  2136 pts/0    S+   11:20   0:00 grep --color=auto netdata
```
```
[user@web ~]$ sudo firewall-cmd --list-all | grep port
[sudo] password for user:
  ports: 80/tcp 19999/tcp
  forward-ports:
  source-ports:
```
```
[user@web ~]$ sudo journalctl -u netdata | tail -n 10
Jan 16 11:14:25 web.tb6.linux systemd[1]: Starting Real time performance monitoring...
Jan 16 11:14:25 web.tb6.linux systemd[1]: Started Real time performance monitoring.
Jan 16 11:14:25 web.tb6.linux netdata[1661]: CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal defaults.
Jan 16 11:14:25 web.tb6.linux netdata[1661]: 2023-01-16 11:14:25: netdata INFO  : MAIN : CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal defaults.
Jan 16 11:14:25 web.tb6.linux netdata[1661]: Found 0 legacy dbengines, setting multidb diskspace to 256MB
Jan 16 11:14:25 web.tb6.linux netdata[1661]: 2023-01-16 11:14:25: netdata INFO  : MAIN : Found 0 legacy dbengines, setting multidb diskspace to 256MB
Jan 16 11:14:25 web.tb6.linux netdata[1661]: Created file '/var/lib/netdata/dbengine_multihost_size' to store the computed value
Jan 16 11:14:25 web.tb6.linux netdata[1661]: 2023-01-16 11:14:25: netdata INFO  : MAIN : Created file '/var/lib/netdata/dbengine_multihost_size' to store the computed value
Jan 16 11:14:30 web.tb6.linux ebpf.plugin[1887]: Does not have a configuration file inside `/etc/netdata/ebpf.d.conf. It will try to load stock file.
Jan 16 11:14:30 web.tb6.linux ebpf.plugin[1887]: Cannot read process groups configuration file '/etc/netdata/apps_groups.conf'. Will try '/usr/lib/netdata/conf.d/apps_groups.conf'
```



🌞 **Configurer Netdata pour qu'il vous envoie des alertes** 


```
[user@db netdata]$ cat /etc/netdata/health_alarm_notify.conf | grep discord
# sending discord notifications
# enable/disable sending discord notifications
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1064492175976566824/hPDcaiu7PRbmkeiDOnMkfOFuM1wRU295WNE2EVXMzvPnpLthiSLyw3-s9-g7yTVIkLrh"
# this discord channel (empty = do not send a notification for unconfigured
role_recipients_discord[sysadmin]="systems"
role_recipients_discord[dba]="databases systems"
role_recipients_discord[webmaster]="marketing development"
```
```
[user@db netdata]$ sudo systemctl restart netdata
```

🌞 **Vérifier que les alertes fonctionnent**

```
[user@db netdata]$ stress --cpu 1
stress: info: [15910] dispatching hogs: 1 cpu, 0 io, 0 vm, 0 hdd
```

```
[user@db netdata]$ cat health.d/cpu.conf | head -n 19

# you can disable an alarm notification by setting the 'to' line to: silent

 template: 10min_cpu_usage
       on: system.cpu
    class: Utilization
     type: System
component: CPU
       os: linux
    hosts: *
   lookup: average -10m unaligned of user,system,softirq,irq,guest
    units: %
    every: 1min
     warn: $this > 10
     crit: $this > (($status == $CRITICAL) ? (85) : (95))
    delay: down 15m multiplier 1.5 max 1h
     info: average CPU utilization over the last 10 minutes (excluding iowait, nice and steal)
       to: sysadmin

```