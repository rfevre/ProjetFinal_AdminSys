#!/usr/bin/perl

########################
## Gestion de l'utf-8 ##
########################

use encoding 'utf8';
use Unicode::Normalize;

$uid_gid=10000;

while(<>) {
    chomp;
    ajouterListe($2, $1) if(/(.*)[\t;,: ](.*)/);
}


####################################
## Foncti0on de création d'un user ##
####################################


sub ajouterListe {
        $nom = shift;
        $prenom = shift;

        $nom = caractereSpecial($nom);
        $prenom = caractereSpecial($prenom);


        $login = lc( substr($nom, 0, 7) . substr($prenom, 0, 1) );

        $nombreDeLigne = 0;
        open(LIRE_LISTE, "files_users/listeLogin.txt");
                while(<LIRE_LISTE>){
                        chomp($_);
                        chomp($login);
                        $nombreDeLigne=$nombreDeLigne+1 if($_ eq $login);
                }
        close(LIRE_LISTE);

        chomp($nombreDeLigne);
        $login .= $nombreDeLigne if($nombreDeLigne >= 1);

        open(LISTE_USER, ">>files_users/listeLogin.txt");
                print LISTE_USER "$login\n";
        close(LISTE_USER);

        open(DOSSIER_USER, ">>files_users/dossierLogin.txt");
                print DOSSIER_USER "/srv/serveur/$login\n";
        close(DOSSIER_USER);

        chomp($login);

        open(FICHIER_LOGIN, ">>config_users/$login.ldif");
                print FICHIER_LOGIN "dn: cn=$login,ou=groupes,dc=da2i,dc=org\n";
                print FICHIER_LOGIN "cn: $login\n";
                print FICHIER_LOGIN "gidNumber: $uid_gid\n";
                print FICHIER_LOGIN "objectClass: top\n";
                print FICHIER_LOGIN "objectClass: posixGroup\n";
                print FICHIER_LOGIN "\n";
                print FICHIER_LOGIN "dn: uid=$login,ou=users,dc=da2i,dc=org\n";
                print FICHIER_LOGIN "uid: $login\n";
                print FICHIER_LOGIN "uidNumber: $uid_gid\n";
                print FICHIER_LOGIN "gidNumber: $uid_gid\n";
                print FICHIER_LOGIN "cn: $login\n";
                print FICHIER_LOGIN "sn: $login\n";
                print FICHIER_LOGIN "objectClass: top\n";
                print FICHIER_LOGIN "objectClass: person\n";
                print FICHIER_LOGIN "objectClass: posixAccount\n";
                print FICHIER_LOGIN "objectClass: shadowAccount\n";
                print FICHIER_LOGIN "loginShell: /bin/bash\n";
                print FICHIER_LOGIN "homeDirectory: /home/$login\n";
        close(FICHIER_LOGIN);

        $uid_gid++;
}


#####################################
## Gestion des caractères spéciaux ##
#####################################

sub caractereSpecial {
        $mot = shift;
        $mot = NFKD($mot); #Normalisation du mot
        $mot =~ s/\p{NonspacingMark}//g; #Suppression des caractères spéciaux
        $mot =~ y/àâäçéèêëîïôöùûü/aaaceeeeiioouuu/; #Suppression des accents
        $mot =~ s/\ //g; #Suppression des espaces
        $mot =~ s/\'//g;
        return $mot;
}