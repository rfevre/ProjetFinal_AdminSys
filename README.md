# Administration système
## Projet final - DA2I
### Par FEVRE Rémy

---

## I/ TODO-list :

- [x] **Serveur Debian :**
  - [x] Authentification des utilisateurs via le service LDAP
  - [x] Stockage des données des utilisateurs et partage de celles-ci via les services NFS
- [x] **Client Debian :**
  - [x] Traitement de texte et tableur via libreoffice
  - [x] Navigateur web via firefox
  - [x] Outil de gestion de mail via thunderbird
- [ ] **Client Archlinux :**
  - [ ] Traitement de texte et tableur via libreoffice
  - [ ] Navigateur web via firefox
  - [ ] Outil de gestion de mail via thunderbird
- [ ] **Client FreeBSD :**
  - [ ] Traitement de texte et tableur via libreoffice
  - [ ] Navigateur web via firefox
  - [ ] Outil de gestion de mail via thunderbird

## II/ Contraintes :

- Les machines virtuelles devront avoir chacune un seul disque virtuel de **10Go.**

- Vos machines devront avoir des **adresses IP fixes** choisies dans le sous-réseau que VMware utilise sur votre poste physique :
  - le dernier octet de l'adresse du serveur devra être **10**
  - le dernier octet de l'adresse du client Debian devra être **20**
  - le dernier octet de l'adresse du client Archlinux devra être **30**
  - le dernier octet de l'adresse du client FreeBSD devra être **40**


- Vos machines constitueront un réseau dont le nom de domaine IP (DNS) devra être `da2i.org`

- Les clients devront avoir des interfaces graphique en **français, anglais et néerlandais.**

- Depuis **n'importe lequel** des 3 postes :
  - Le serveur devra être joignable sous le nom `serveur.da2i.org`
  - les clients devront être joignables sous le nom `<distribution>.da2i.org`


- La résolution des noms pourra être faite aux choix via **un service DNS** (par
 exemple bind9) installé sur le serveur ou plus simplement par **les fichiers
 locaux** (hosts).

- Sur le serveur, **aucun utilisateur, ormis root**, ne devra pouvoir se loguer
  directement aussi bien sur une de ses consoles que par ssh. Le serveur devra
  néanmoins connaître les utilisateurs.

- Les clients devront avoir une **résolution graphique de 800x600 pixels.**

- Le serveur ne devra être **accessible qu'en mode texte.**

- Les utilisateurs bernard, georges et robert posséderont un compte identifié via
  ldap et, pour simplifier, de **mot de passe identique à leur login.**

## III/ Stockage des données :

- Sur le serveur un répertoire `/srv` devra être accessible et correspondre à une partition différente de celle contenant le système.

- Sur le serveur les répertoires de stockage des données utilisateurs seront créés en respectant le schéma de nommage suivant :
  - `/srv/home/login`


- Sur les clients les répertoires de stockage des utilisateurs seront accessibles en respectant le modèle de nommage suivant (ils seront montés en utilisant le protocole NFS):
  - `/home/login`


## IV/ Serveur

### 1) Installation de la machine virtuel

L'installation de la machine virtuel serveur ce fait grâce à un iso téléchargeable sur le site suivant (**"mini.iso"**):

http://ftp.nl.debian.org/debian/dists/jessie/main/installer-amd64/current/images/netboot/

Ensuite sur le logiciel VMware Player, voici les étapes à suivre :

- Créer une nouvelle machine
- Sélectionner l'iso téléchargé précédement (**"mini.iso"**),puis suivant
- Sélectionner **Debian 6**, puis suivant
- Mettre **10 GB** d'espace disque, puis suivant jusqu'à avoir Terminer.

A ce moment là, Débian va commencer à ce lancer, maintenant nous devons faire ceci :

- **Installer**
- Pour la langue choisir : **Français**
- Nom de la machine : **server**
- Nom du domain : **da2i.org**
- Pays : **France**
- Package : **debian.polytech-lille.fr**
- Proxy : **http://cache.univ-lille1.fr:3128/**
- Mot de passe SuperUtilisateur : **root**
- Utilisateur : **fevrer** | Mot de passe : **root**
- Installer manuellement le disque dur
- Créer une nouvelle partition : **Oui**
- Aller dans : **SCSII (0,0,0) (sda) 10.7 GB VMWARE VMWARE VIRTUALS**
- Aller dans : **pri/log 10.7 GB espace libre**
- Créer une nouvelle partition : **4 GB -> Primaire -> début -> 'ext 4' -> / -> Fin**
- Créer une nouvelle partition : **200 MB -> Primaire -> début -> 'ext 4' -> /home -> Fin**
- Créer une nouvelle partition : **1 GB -> Primaire -> début -> 'swap' -> Fin**
- Créer une nouvelle partition : **5.5 GB -> Primaire -> début -> 'ext 4' -> /srv -> Fin**
- Terminer : **Oui**
- Pas de paquet et pas de participation aux expériences
- Ensuite il faut décocher tout **SAUF** ssh et utilitaire usuel
- Installer le GRUB sur la partition d'amorçage du système : **Oui**
- Après ça, un message disant que tout s'est bien déroulé devrait apparaitre (normalement).

Debian redémarra alors pour mettre à jour les données. Il suffira de se connecter avec le login root et son mot de passe root.

### 2) Configuration du DNS (Domaine Name Server)

Tout d'abord, il faut modifier le fichier de configuration interfaces :

`vim /etc/network/interfaces`

Commenter ou supprimer les lignes suivantes :
````
allow-hotplug eth0
iface eth0 inet dhcp
````
Et on ajoute ceci au fichier :
````
auto eth0
iface eth0  inet static
address 192.168.194.10
netmask 255.255.255.0
gateway 192.168.194.2 			#Gateway VMware Player
````
Ensuite, on peut relancer la configuration de notre adresse IP :

`/etc/init.d/networking restart`

### 3) Configuration de Bind9

L'installation de Bind9 s'effectue comme suit :

`apt-get install bind9`

Après l'installation, on va pouvoir configurer 3 fichiers :

- **named.conf.options**
- **named.conf.local**
- **named.conf.resolv.conf**

On va commencer par le fichier **named.conf.options**, pour ainsi pouvoir configurer les adresse IP DNS afin que le serveur puisse se connecter à certain DNS exterieur.

`vim /etc/bind/named.conf.options`

````
forwarders {
	192.168.194.2; 	#IP de vmPlayer
	172.18.48.31;	#DNS Universite
};
````

**/!\ ATTENTION /!\** Avant de sauvegarder et de fermer le fichier, il faut modifier la valeur de **dnssec-validation** et le passer de **auto** à **no**.

On peut ensuite modifier le fichier **named.conf.local**. Ce fichier permet de définir des "zones" et "reverse zone" pour pouvoir traduire les adresses ip lorsque l'on rentrera un nom de domaine, et réciproquement.

`vim /etc/bind/named.conf.local`

````
zone "da2i.org" {
    type master;
    file "/etc/bind/zones/db.da2i.org";
};

zone "194.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192";
};
````

Nous devons ensuite créer les deux fichiers **db.da2i.org** & **db.192** et son dossier **"zones"**.

`mkdir /etc/bind/zones`

On peut ensuite créer les fichiers :
````
cp /etc/bind/db.local /etc/bind/zones/db.da2i.org
cp /etc/bind/db.127 /etc/bind/zones/db.192
Configurons d'abord le premier fichier :
````
`vim /etc/bind/zones/db.da2i.org`

**/!\ ATTENTION /!\** A BIEN ECRIRE SANS OUBLIER LES POINTS ET AUTRES SIGNES
````
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     server.da2i.org. webuser.da2i.org. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
da2i.org.       IN      NS      server.da2i.org.
da2i.org.       IN      A       192.168.194.10
;@      IN      NS      localhost.
;@      IN      A       127.0.0.1
;@      IN      AAAA    ::1
server  IN      A       192.168.194.10
gateway IN      A       192.168.194.2
debian  IN      A       192.168.194.20
archlinux       IN      A       192.168.194.30
freebsd IN      A       192.168.194.40
www     IN      CNAME   da2i.org.
````
On peut ensuite s'occuper du second fichier :

`vim /etc/bind/zones/db.192`
````
;
; BIND reverse data file for local loopback interface
;
$TTL    604800
@       IN      SOA     server.da2i.org. webuser.da2i.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
;@      IN      NS      localhost.
;1.0.0  IN      PTR     localhost.
        IN      NS      server.
2       IN      PTR     gateway.da2i.org.
10      IN      PTR     server.da2i.org.
20      IN      PTR     debian.da2i.org.
30      IN      PTR     archlinux.da2i.org.
40      IN      PTR     freebsd.da2i.org.
````
Pour vérifier si il n'y à pas de faute, faite ceci :

`named-checkzone da2i.org /etc/bind/zones/db.da2i.org`

Le résultat attendu devrait être :

````
zone da2i.org /IN: loaded serial 2
Ok
````
Pour le second fichier :
````
named-checkzone da2i.org /etc/bind/zones/db.192
zone da2i.org /IN: loaded serial 1
Ok
````
Maintenant, nous pouvons modifier le fichier **resolv.conf** :

`vim /etc/resolv.conf`
````
domain da2i.org
search da2i.org
nameserver 192.168.194.10
````
Nous avons enfin un **dns-nameservers** que l'on peut ajouter dans le fichier **/etc/network/interfaces** :

`vim /etc/network/interfaces`
````
dns-nameservers 192.168.194.10
````
Et enfin, on redémarre le service Bind9

`/etc/init.d/bind9 restart`

### 4) Installation et configuration du serveur LDAP

Pour installer LDAP :

`apt-get install slapd ldap-utils`

On configure le serveur comme ceci :

- Omit OpenLDAP server configuration? **No**
- DNS domain name : **da2i.org**
- Organization name? **da2i.org**
- Administrator password : **root**
- Confirm password : **root**
- Database backend to use : **HDB**
- Do you want the database to be removed when slapd is purged? **No**
- Allow LDAPv2 protocol? **No**

Pour pouvoir se connecter seulement en root au LDAP, ainsi que sur le serveur.
Voici les configurations nécessaire :
````
ldapadd -c -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/core.ldif
ldapadd -c -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/cosine.ldif
ldapadd -c -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/nis.ldif
ldapadd -c -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/inetorgperson.ldif
````

Ensuite, pour remplacer la valeur par défaut **olcLogLevel: none** par **olcLogLevel: 256** :
````
echo "dn: cn=config
changetype: modify
replace: olcLogLevel
olcLogLevel: 256" > /var/tmp/loglevel.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f /var/tmp/loglevel.ldif
````
Pour avoir un "équivalent" d'un index de recherche grâce à l'uid :
````
echo "
dn: olcDatabase={1}hdb,cn=config
changetype: modify
add: olcDbIndex
olcDbIndex: uid eq
" > /var/tmp/uid_eq.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f /var/tmp/uid_eq.ldif
````
Enfin, nous voulons que l'administrateur puisse accéder au LDAP et modifier le **cn=config** en mode d'écriture pour **dc=da2i,dc=org** :
````
echo "dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcAccess
olcAccess: to * by dn="cn=admin,dc=da2i,dc=org" write" > /var/tmp/access.ldif
ldapmodify -c -Y EXTERNAL -H ldapi:/// -f /var/tmp/access.ldif
````
Pour vérifier si le serveur LDAP fonctionne bien, on va vérifier dans le **/etc/ldap/ldap.conf** s'il y a bien ces deux lignes :
````
BASE  dc=da2i, dc=org
URI ldap://192.168.194.10/
````
Et enfin on peut vérifier le contenu du LDAP sur le serveur :

`ldapsearch -x`

On obtient normalement ceci :
````
# extended LDIF
#
# LDAPv3
# base dc=da2i,dc=org (default) with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# da2i.org
dn: dc=da2i,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: da2i.org
dc: da2i

# admin, da2i.org
dn: cn=admin,dc=da2i,dc=org
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2
````
Le serveur LDAP est bien configuré, nous pouvons commencer à créer l'arbre.

Nous avons créé deux "organizational units" : **users** et **groupes** qui correspondra à **/etc/passwd** et **/etc/group**.
On va créer un fichier temporaire pour y ajouter l'arbres :
````
touch /var/tmp/ou.ldif
dn: ou=users,dc=da2i,dc=org
ou: users
objectClass: organizationalUnit

dn: ou=groupes,dc=da2i,dc=org
ou: groupes
objectClass: organizationalUnit
````
Pour charger le fichier au ldap, nous devons l'éteindre et utiliser la méthode slapadd :
````
invoke-rc.d slapd stop
slapadd -c -v -l /var/tmp/ou.ldif
````
Si nous faisons une recherche sur une des deux "organizational units", nous devrions obtenir :
````
# extended LDIF
#
# LDAPv3
# base dc=da2i,dc=org (default) with scope subtree
# filter: ou=users
# requesting: ALL
#

# users, da2i.org
dn: ou=users,dc=da2i,dc=org
ou: users
objectClass: organizationalUnit

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
````
L'arbre étant créé, nous pouvons créer un utilisateur pour faire les tests :
````
nano /var/tmp/user1.ldif
dn: cn=fevrer,ou=groupes,dc=da2i,dc=org
cn: fevrer
gidNumber: 1001
objectClass: top
objectClass: posixGroup

dn: uid=fevrer,ou=users,dc=da2i,dc=org
uid: fevrer
uidNumber: 1001
gidNumber: 1001
cn: Fevrer
sn: Fevrer
objectClass: top
objectClass: person
objectClass: posixAccount
objectClass: shadowAccount
loginShell: /bin/bash
homeDirectory: /home/fevrer
````
Le serveur toujours éteind, nous pouvons faire, plus ou moins, la même commande que précédemment pour charger le fichier dans le serveur ldap :

`ldapadd -c -x -D cn=admin,dc=da2i,dc=org -W -f /var/tmp/user1.ldif`

Nous allons à présent charger un mot de passe pour l'utilisateur :
````
ldappasswd -x -D cn=admin,dc=da2i,dc=org -W -S uid=fevrer,ou=users,dc=da2i,dc=org
New password: NEW USER PASSWORD
Re-enter new password:  NEW USER PASSWORD
Enter LDAP Password:   ADMIN PASSWORD
````
Nous pouvons vérifier l'ajout de l'utilisateur :

`ldapsearch -x uid=fevrer`
````
# extended LDIF
#
# LDAPv3
# base dc=da2i,dc=org (default) with scope subtree
# filter: uid=fevrer
# requesting: ALL
#

# fevrer, users, da2i.org
dn: uid=fevrer,ou=users,dc=da2i,dc=org
uid: fevrer
uidNumber: 1001
gidNumber: 1001
cn: fevrer
sn: fevrer
objectClass: top
objectClass: person
objectClass: posixAccount
objectClass: shadowAccount
loginShell: /bin/bash
homeDirectory: /home/fevrer

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
````
Le serveur fonctionne bien et est à présent prêt à fonctionner sur un client.

### 5) Configuration NFS

Nous allons à présent configurer le serveur nfs. Pour cela, commencer à installer **"nfs-kernel-server"** :

`apt-get install nfs-kernel-server`

Une fois que c'est installé, nous allons configurer l'exports de montage :

`vim /etc/exports`
````
/srv/home 192.168.194.10/255.255.255.0(rw,sync,no_subtree_check)
````
A présent nous allons lancer le serveur nfs :

`/etc/init.d/nfs-kernel-server start`

On peut tester le montage NFS :

- **Sur le Serveur :**
````
mkdir /srv/home
mkdir /srv/home/fevrer
chmod go+rwx /srv/home/fevrer
touch /srv/home/fevrer/toto
````
- **Sur le Client :**
````
mount 192.168.194.10:/srv/home /home
````
On voit alors le fichier toto dans le dossier, c'est le fichier toto créé dans le serveur.
On voit donc que le client peut monter la partition **/srv** du serveur

**/!\ ATTENTION /!\** Le client devra configurer son fichier **/etc/fstab** pour pouvoir monter le dossier **/srv/home/"Nom User"**.

## V/ Client Debian

### 1) Installation de la machine virtuel

L'installation de la machine virtuel Debian ce fait grâce à un iso téléchargeable sur le site suivant (**"mini.iso"**):

http://ftp.nl.debian.org/debian/dists/jessie/main/installer-amd64/current/images/netboot/

Ensuite sur le logiciel VMware Player, voici les étapes à suivre :

- Créer une nouvelle machine
- Sélectionner l'iso téléchargé précédement (**"mini.iso"**),puis suivant
- Sélectionner **Debian 6**, puis suivant
- Mettre **10 GB** d'espace disque, puis suivant jusqu'à avoir Terminer.

A ce moment là, Débian va commencer à ce lancer, maintenant nous devons faire ceci :

- **Installer**
- Pour les langues choisir : **Français**
- Nom de la machine : **debian**
- Nom du domain : **da2i.org**
- Pays : **France**
- Package : **debian.polytech-lille.fr**
- Proxy : **http://cache.univ-lille1.fr:3128/**
- Mot de passe SuperUtilisateur : **root**
- Utilisateur : **fevrer** | Mot de passe : **root**
- Installer le disque dur à l'aide de l'assistance
- Pas de paquet et pas de participation aux expériences.
- Il faut décocher tout SAUF Environnement graphique de bureau, ssh, utilitaire usuel
- Installer le GRUB sur la partition d'amorçage du système : **Oui**
- Après ça, un message disant que tout s'est bien déroulé devrait apparaitre (normalement)

Debian redémarra pour mettre à jour les données. Il suffira de se connecter avec le login root et son mot de passe root.

### 2) Configuration IP

Comme pour le serveur :

`vim /etc/network/interface`

On commente ces lignes :
````
# allow-hotplug eth0
# iface eth0 inet dhcp
````
Puis ajouter ces lignes :
````
auto eth0
iface eth0 inet static
address 192.168.194.20
netmask 255.255.255.0
gateway 192.168.194.2
dns-nameservers 192.168.194.10
````
Et on relance le network :

`/etc/init.d/networking restart`

### 3) Installation et Configuration NFS

Nous allons faire en sorte de pouvoir accéder au LDAP depuis le client :

`apt-get install libnss-ldap libpam-ldap nscd`
````
LDAP server URI : **ldap://192.168.194.10/**
Distinguished name of the search base : **dc=da2i,dc=org**
LDAP version to use : **3**
Special LDAP privileges for root? **No**
Make the configuration file readable/writable by its owner only? **No**
Allow LDAP admin account to behave like local root? **Yes**
Make local root Database admin : **No**
Does the LDAP database require login? **No**
LDAP administrative account : **cn=admin,dc=da2i,dc=org**
LDAP administrative password : **root**
DLocal crypt to use when changing passwords : **md5**
````
Si on obtient pas une des demandes ci-dessous, il faut alors faire un **dpkg-reconfigure** avec soit **libnss-ldap** ou **libpam-ldap**.
Ensuite, on vérifie qu'il y a bien les configurations serveur suivante :
````
/etc/libnss-ldap.conf
base dc=da2i,dc=org
uri ldap://192.168.194.10/
````
Il faut activer le module LDAP NSS :

`vim /etc/nsswitch.conf`
````
passwd:         files ldap
group:          files ldap
````
Pendant les tests nous allons éteindre le NCSD :

`invoke-rc.d nscd stop`

Nous pouvons vérifier ensuite :
````
id fevrer
uid=1001(fevrer) gid=1001(fevrer) groups=1001(fevrer)
````

le client a donc accès au LDAP du serveur.

Nous allons à présent faire en sorte d'avoir une procédure d'authentification au système à partir du LDAP du serveur.
Nous allons donc vérifier/modifier 4 fichiers pour avoir les mêmes lignes. Tout d'abord :**/etc/pam.d/common-account**
````
account [success=2 new_authtok_reqd=done default=ignore]        pam_unix.so
account [success=1 default=ignore]      pam_ldap.so

account requisite                       pam_deny.so

account required                        pam_permit.so
````
Ensuite : **/etc/pam.d/common-auth**
````
auth    [success=2 default=ignore]      pam_unix.so nullok_secure
auth    [success=1 default=ignore]      pam_ldap.so use_first_pass

auth    requisite                       pam_deny.so

auth    required                        pam_permit.so
````
Ensuite : **/etc/pam.d/common-passwd**
````
password        [success=2 default=ignore]      pam_unix.so obscure sha512
password        [success=1 user_unknown=ignore default=die]     pam_ldap.so use_authtok try_first_pass

password        requisite                       pam_deny.so

password        required                        pam_permit.so
````
Et enfin : **/etc/pam.d/common-session**
````
session [default=1]                     pam_permit.so

session requisite                       pam_deny.so

session required                        pam_permit.so

session required        pam_unix.so
````
Nous pouvons redémarrer la machine client Debian. A la page d'accueil nous aurons les identifiants du LDAP serveur.

Pour pouvoir monter le disque **/srv/home/** sur le client et pour que le client puisse avoir son **/home** à sa connection, il faut modifier le fichier **/etc/fstab** pour ajouter la ligne :
````
192.168.194.10:/srv/home 	/home 	nfs4 	auto 	0 	0
````
On relance la machine client et on pourra alors accéder au fichier.
