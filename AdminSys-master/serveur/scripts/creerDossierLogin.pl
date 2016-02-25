#!/usr/bin/perl

open(LIRE_LISTE, "files_users/dossierLogin.txt");
        while (<LIRE_LISTE>){
            chomp($_);
            mkdir $_;
        }
close(LIRE_LISTE);
