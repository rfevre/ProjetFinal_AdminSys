#!/usr/bin/perl

open(LIRE_DOSSIER, "files_users/dossierLogin.txt");
	while (<LIRE_DOSSIER>){
		if(/[\/](.*)[\/](.*)[\/](.*)/){
			$login = $3;
		}
		my($log,$pass,$uid,$gid)=getpwnam($login);
		print "$uid $gid \n";
		print "$_";
		chomp($_);
		chown $uid,$gid,$_;
	}
close(LIRE_DOSSIER);
