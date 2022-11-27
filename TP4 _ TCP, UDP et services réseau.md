# TP4 : TCP, UDP et services réseau

![TCP UDP](./pics/tcp_udp.jpg)

# Sommaire

- [TP4 : TCP, UDP et services réseau](#tp4--tcp-udp-et-services-réseau)
- [Sommaire](#sommaire)
- [0. Prérequis](#0-prérequis)
- [I. First steps](#i-first-steps)
- [II. Mise en place](#ii-mise-en-place)
  - [1. SSH](#1-ssh)
  - [2. Routage](#2-routage)
- [III. DNS](#iii-dns)
  - [1. Présentation](#1-présentation)
  - [2. Setup](#2-setup)
  - [3. Test](#3-test)


# I. First steps

🌞 **Déterminez, pour ces 5 applications, si c'est du TCP ou de l'UDP**

- avec Wireshark, on va faire les chirurgiens réseau
- déterminez, pour chaque application :
  - IP et port du serveur auquel vous vous connectez
  - le port local que vous ouvrez pour vous connecter


  League Of Legend:
  
```
  b@DESKTOP-0JKFI2T MINGW64 ~ (master)
$ netstat  -b -n -p udp -a

       UDP    0.0.0.0:60408          *:*
 [League of Legends.exe]
```
[lol](./capture_lol.pcapng)


Discord : 

```
b@DESKTOP-0JKFI2T MINGW64 ~ (master)
$ netstat  -b -n -p udp -a

  UDP    0.0.0.0:52540          *:*
 [Discord.exe]
```
[discord](./capture_discord.pcapng)


Steam : 

```
b@DESKTOP-0JKFI2T MINGW64 ~ (master)
$ netstat  -b -n -p udp -a | grep 62027 -A 1
  UDP    0.0.0.0:62027          *:*
 [System]
 ```
[Steam](./capture_steam.pcapng)



Roblox :

 ```
b@DESKTOP-0JKFI2T MINGW64 ~ (master)
$ netstat -b -n
TCP    10.33.17.19:61476      96.16.122.82:443       CLOSE_WAIT
 [Roblox.exe]
```
[roblox](./capture_roblox.pcapng)



Overwatch:

```
b@DESKTOP-0JKFI2T MINGW64 ~ (master)
$ netstat  -b -n -p udp -a
  UDP    0.0.0.0:60720          *:*
 [Overwatch.exe]
```


[overwatch](./capture_overwatch.pcapng)


# II. Mise en place

## 1. SSH

🖥️ **Machine `node1.tp4.b1`**

- n'oubliez pas de dérouler la checklist (voir [les prérequis du TP](#0-prérequis))
- donnez lui l'adresse IP `10.4.1.11/24`

Connectez-vous en SSH à votre VM.

🌞 **Examinez le trafic dans Wireshark**

- **déterminez si SSH utilise TCP ou UDP**

  ```
  b@DESKTOP-0JHFY4T MINGW64 ~ (master)
$ netstat -n -b

Connexions actives

  Proto  Adresse locale         Adresse distante       ▒tat
  TCP    10.4.1.1:58505         10.4.1.11:22           TIME_WAIT
  TCP    10.4.1.1:42237         10.4.1.254:22          ESTABLISHED
 [ssh.exe]
```

🦈 **Je veux une capture clean avec le 3-way handshake, un peu de trafic au milieu et une fin de connexion**
[handshake](./handshake.pcapng)
## 2. Routage

# III. DNS

## 2. Setup

🖥️ **Machine `dns-server.tp4.b1`**

Installation du serveur DNS :

```bash
# assurez-vous que votre machine est à jour
$ sudo dnf update -y

# installation du serveur DNS, son p'tit nom c'est BIND9
$ sudo dnf install -y bind bind-utils
```

La configuration du serveur DNS va se faire dans 3 fichiers essentiellement :

- **un fichier de configuration principal**
  - `/etc/named.conf`
  - on définit les trucs généraux, comme les adresses IP et le port où on veu écouter
  - on définit aussi un chemin vers les autres fichiers, les fichiers de zone
- **un fichier de zone**
  - `/var/named/tp4.b1.db`
  - je vous préviens, la syntaxe fait mal
  - on peut y définir des correspondances `IP ---> nom`
- **un fichier de zone inverse**
  - `/var/named/tp4.b1.rev`
  - on peut y définir des correspondances `nom ---> IP`

➜ **Allooooons-y, fichier de conf principal**

```bash
# éditez le fichier de config principal pour qu'il ressemble à :
```
[titim@dnsserver /]$ sudo cat /etc/named.conf
[sudo] password for titim:
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//

options {
        listen-on port 53 { 127.0.0.1; any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { localhost; any; };
        allow-query-cache { localhost; any; };
        /*
         - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
         - If you are building a RECURSIVE (caching) DNS server, you need to enable
           recursion.
         - If your recursive DNS server has a public IP address, you MUST enable access
           control to limit queries to your legitimate users. Failing to do so will
           cause your server to become part of large scale DNS amplification
           attacks. Implementing BCP38 within your network would greatly
           reduce such attack surface
        */
        recursion yes;

        dnssec-validation yes;

        managed-keys-directory "/var/named/dynamic";
        geoip-directory "/usr/share/GeoIP";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";

        /* https://fedoraproject.org/wiki/Changes/CryptoPolicy */
        include "/etc/crypto-policies/back-ends/bind.config";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "tp4.b1" IN {
     type master;
     file "tp4.b1.db";
     allow-update { none; };
     allow-query {any; };
};
# référence vers notre fichier de zone inverse
zone "1.4.10.in-addr.arpa" IN {
     type master;
     file "tp4.b1.rev";
     allow-update { none; };
     allow-query { any; };
};
```

➜ **Et pour les fichiers de zone**

```bash
# Fichier de zone pour nom -> IP

[titim@dnsserver /]$ sudo cat var/named/tp4.b1.db
$TTL 86400
@ IN SOA dns-server.tp4.b1. admin.tp4.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns-server.tp4.b1.

; Enregistrements DNS pour faire correspondre des noms à des IPs
dns-server IN A 10.4.1.201
node1      IN A 10.4.1.11
```

```bash
# Fichier de zone inverse pour IP -> nom

[titim@dnsserver /]$ sudo cat /var/named/tp4.b1.rev
$TTL 86400
@ IN SOA dns-server.tp4.b1. admin.tp4.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns-server.tp4.b1.

;Reverse lookup for Name Server
201 IN PTR dns-server.tp4.b1.
11 IN PTR node1.tp4.b1.
[titim@dnsserver /]$ sudo nano var/named/tp4.b1.db
[titim@dnsserver /]$ sudo nano var/named/tp4.b1.rev
[titim@dnsserver /]$ sudo cat var/named/tp4.b1.rev
$TTL 86400
@ IN SOA dns-server.tp4.b1. admin.tp4.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns-server.tp4.b1.

;Reverse lookup for Name Server
201 IN PTR dns-server.tp4.b1.
11 IN PTR node1.tp4.b1.
```

🌞 **Dans le rendu, je veux**

- un `cat` des fichiers de conf
- un `systemctl status named` qui prouve que le service tourne bien
```
[titim@dnsserver /]$ sudo systemctl status named
● named.service - Berkeley Internet Name Domain (DNS)
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-11-22 15:05:58 CET; 43s ago
   Main PID: 952 (named)
      Tasks: 4 (limit: 5905)
     Memory: 16.3M
        CPU: 45ms
     CGroup: /system.slice/named.service
             └─952 /usr/sbin/named -u named -c /etc/named.conf

Nov 22 15:05:58 dnsserver named[952]: configuring command channel from '/etc/rndc.key'
Nov 22 15:05:58 dnsserver named[952]: command channel listening on 127.0.0.1#953
Nov 22 15:05:58 dnsserver named[952]: configuring command channel from '/etc/rndc.key'
Nov 22 15:05:58 dnsserver named[952]: command channel listening on ::1#953
Nov 22 15:05:58 dnsserver named[952]: managed-keys-zone: loaded serial 0
Nov 22 15:05:58 dnsserver named[952]: zone 1.4.10.in-addr.arpa/IN: loaded serial 2019061800
Nov 22 15:05:58 dnsserver named[952]: zone tp4.b1/IN: loaded serial 2019061800
Nov 22 15:05:58 dnsserver named[952]: all zones loaded
Nov 22 15:05:58 dnsserver systemd[1]: Started Berkeley Internet Name Domain (DNS).
Nov 22 15:05:58 dnsserver named[952]: running
```
- une commande `ss` qui prouve que le service écoute bien sur un port
```
[titim@dnsserver /]$ sudo ss -tulpn
Netid   State    Recv-Q   Send-Q       Local Address:Port       Peer Address:Port   Process
udp     UNCONN   0        0               10.4.1.201:53              0.0.0.0:*       users:(("named",pid=952,fd=19))
udp     UNCONN   0        0                127.0.0.1:53              0.0.0.0:*       users:(("named",pid=952,fd=16))
udp     UNCONN   0        0                127.0.0.1:323             0.0.0.0:*       users:(("chronyd",pid=649,fd=5))
udp     UNCONN   0        0                    [::1]:53                 [::]:*       users:(("named",pid=952,fd=22))
udp     UNCONN   0        0                    [::1]:323                [::]:*       users:(("chronyd",pid=649,fd=6))
tcp     LISTEN   0        10              10.4.1.201:53              0.0.0.0:*       users:(("named",pid=952,fd=21))
tcp     LISTEN   0        10               127.0.0.1:53              0.0.0.0:*       users:(("named",pid=952,fd=17))
tcp     LISTEN   0        128                0.0.0.0:22              0.0.0.0:*       users:(("sshd",pid=707,fd=3))
tcp     LISTEN   0        4096             127.0.0.1:953             0.0.0.0:*       users:(("named",pid=952,fd=24))
tcp     LISTEN   0        10                   [::1]:53                 [::]:*       users:(("named",pid=952,fd=23))
tcp     LISTEN   0        128                   [::]:22                 [::]:*       users:(("sshd",pid=707,fd=4))
tcp     LISTEN   0        4096                 [::1]:953                [::]:*       users:(("named",pid=952,fd=25))
```
🌞 **Ouvrez le bon port dans le firewall**

- grâce à la commande `ss` vous devrez avoir repéré sur quel port tourne le service
```
[titim@dnsserver /]$  sudo firewall-cmd --add-port=57599/tcp --permanent
success
[titim@dnsserver /]$ sudo firewall-cmd --reload
success
```
  - vous l'avez écrit dans la conf aussi toute façon :)
- ouvrez ce port dans le firewall de la machine `dns-server.tp4.b1` (voir le mémo réseau Rocky)

## 3. Test

🌞 **Sur la machine `node1.tp4.b1`**

- configurez la machine pour qu'elle utilise votre serveur DNS quand elle a besoin de résoudre des noms
- assurez vous que vous pouvez :
  - résoudre des noms comme `node1.tp4.b1` et `dns-server.tp4.b1`
  ```
  [titim@node1 /]$ dig node1.tp4.b1

  ; <<>> DiG 9.16.23-RH <<>> node1.tp4.b1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 48299
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;node1.tp4.b1.                  IN      A

;; AUTHORITY SECTION:
.                       86319   IN      SOA     a.root-servers.net. nstld.verisign-grs.com. 2022111300 1800 900 604800 86400

;; Query time: 28 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Thu Nov 10 11:55:24 CET 2022
;; MSG SIZE  rcvd: 116
```

  - mais aussi des noms comme `www.google.com`
  ```
  [titim@node1 /]$ dig google.com
  
  ; <<>> DiG 9.16.23-RH <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64279
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             36      IN      A       216.58.214.78

;; Query time: 21 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Thu Nov 10 11:57:23 CET 2022
;; MSG SIZE  rcvd: 55
```

🌞 **Sur votre PC**

- utilisez une commande pour résoudre le nom `node1.tp4.b1` en utilisant `10.4.1.201` comme serveur DNS

> Le fait que votre serveur DNS puisse résoudre un nom comme `www.google.com`, ça s'appelle la récursivité et c'est activé avec la ligne `recursion yes;` dans le fichier de conf.

🦈 **Capture d'une requête DNS vers le nom `node1.tp4.b1` ainsi que la réponse**
