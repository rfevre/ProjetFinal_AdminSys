#!/usr/bin/perl

open(LIRE_LISTE, "files_users/listeLogin.txt");
        while (<LIRE_LISTE>){
                chomp($_);
		$login = $_;
                ` ldapadd -c -x -D cn=admin,dc=da2i,dc=org -w root  -f config_users/$login.ldif `;
		` ldappasswd -x -D cn=admin,dc=da2i,dc=org -w root -s $login uid=$login,ou=users,dc=da2i,dc=org `;
        }
close(LIRE_LISTE);
