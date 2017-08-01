#!/bin/env perl
#
#This script checks and reports all the softwares installed
# On a given machine 
#
#
# Author : lnh - 09/2014
# 
use vars qw ($opt_h $opt_c);
use Getopt::Std;
getopts('hc:');

if(($opt_h)||!($opt_c)){
 print <<HELP;
 This script checks and reports all the softwares installed
 On a given machine 

 Input : 
    -c mgiinstalls Configuration file (required)
 
 Usage:
   ./program -c ../Configuration

HELP
exit(1);
}
#
# This funtion generates tree unique maps of servers. One for test , one for
# production, and one for dmz servers
# These maps will be used by subsequent functions
#
sub load_serverList{
 my($testserverfile,$prodserverfile,$testservers_ref,$prodservers_ref,$dmzServers_ref)=@_;
 if(-f $testserverfile){
   open(IN,"$testserverfile");
   while(<IN>){$server=$_;
     next if($server=~/^#/);next if(!(length $server)); next if($server eq "");
     chomp($server);${$testservers_ref}{"$server"}=-1;
   }close(IN);
 }
 if(-f $prodserverfile){
   open(IN,"$prodserverfile");
   while(<IN>){
     $server=$_;
     next if($server=~/^#/);next if(!(length $server)); next if($server eq "");
     chomp($server);($type,$server)=split(",",$server);
     ${$prodservers_ref}{"$server"}=-1 if($type=~/live/);
     ${$dmzServers_ref}{"$server"}=-1 if($type=~/build/);
   }close(IN);
 }
}
$current_host=`uname -n`;
chomp($current_host);
$current_usr=$ENV{LOGNAME} || $ENV{USER} || getpwuid($<);
chomp($current_usr);

%shell=("sh"=>"","csh"=>"","bash"=>"");
%compilers_lang=("perl"=>"",
       "php"=>"",
       "java"=>"",
       "gcc"=>"",
       "gdb"=>"",
       "python"=>""
        );

%editors=("pico"=>"",
          "gedit"=>"",
          "emacs"=>"",
          "xemacs"=>"",
          "vi"=>"",
          "vim"=>""
        );
%source_control=("cvs"=>"",
            "svn"=>"",
            "git"=>"");
%dbms=("mysql"=>"", "postgres"=>"","sybase"=>"");
%tools=("doxygen"=>"","eclipse"=>"");

$config_file=$opt_c;$testserverfile="";$prodserverfile="";
#
#get global variables(servers file, manifest file) from config file
#
$logdir="";
open(CONF,"$config_file") or die "$!\n";
while(<CONF>){
  chomp($_);($label,$filepath)=split("=",$_);
  $testserverfile=$filepath if($label eq "SERVERLIST_TEST");
  $prodserverfile=$filepath if($label eq "SERVERLIST");
  $logdir=$filepath if($label eq "LOG_DIR");
}close(CONF);
$logfile="$logdir/getServerSoft.pl.log";
open(LOG,">$logfile");
#
# Initiate server lists and set target servers where to install new tags
#
%prodServers=();%testServers=();%dmzServers=();%tagsMap=();%targetServers=();
print LOG "Getting servers List by type  into memory\n";
&load_serverList($testserverfile,$prodserverfile,\%testServers,\%prodServers,\%dmzServers);


