# Administration système - Projet final - DA2I
## Par FEVRE Rémy

---

## TODO :

- [ ] **Serveur Debian :**
  - [ ] Authentification des utilisateurs via le service LDAP
  - [ ] Stockage des données des utilisateurs et partage de celles-ci via les services NFS
- [ ] **Client Debian :**
  - [ ] Traitement de texte et tableur via libreoffice
  - [ ] Navigateur web via firefox
  - [ ] Outil de gestion de mail via thunderbird
- [ ] **Client Archlinux :**
  - [ ] Traitement de texte et tableur via libreoffice
  - [ ] Navigateur web via firefox
  - [ ] Outil de gestion de mail via thunderbird
- [ ] **Client FreeBSD :**
  - [ ] Traitement de texte et tableur via libreoffice
  - [ ] Navigateur web via firefox
  - [ ] Outil de gestion de mail via thunderbird

## Contraintes :

- Les machines virtuelles devront avoir chacune un seul disque virtuel de **10Go.**

- Vos machines devront avoir des **adresses IP fixes** choisies dans le sous-réseau que VMware utilise sur votre poste physique :
  - le dernier octet de l'adresse du serveur devra être **10**
  - le dernier octet de l'adresse du client Debian devra être **20**
  - le dernier octet de l'adresse du client Archlinux devra être **30**
  - le dernier octet de l'adresse du client FreeBSD devra être **40**


- Vos machines constitueront un réseau dont le nom de domaine IP (DNS) devra être **da2i.org**.

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

## Stockage des données :

- Sur le serveur un répertoire `/srv` devra être accessible et correspondre à une partition différente de celle contenant le système.

- Sur le serveur les répertoires de stockage des données utilisateurs seront créés en respectant le schéma de nommage suivant :
  - `/srv/home/login`


- Sur les clients les répertoires de stockage des utilisateurs seront accessibles en respectant le modèle de nommage suivant (ils seront montés en utilisant le protocole NFS):
  - `/home/login`
