#!/usr/bin/env perl

#
# Author : lnh - 09/2014
# 
use vars qw ($opt_h $opt_f $opt_s $opt_c $opt_l $opt_t $opt_o $opt_r $opt_n $opt_j);
use Getopt::Std;
getopts('hf:c:s:t:lo:r:n:j:');

if(($opt_h)||!($opt_c)||!($opt_f)){
 print <<HELP;
This script installs new MGI software product tags on the specified servers type. 
If the option -l is specified, the program lists all the test,production,or dmz servers 
where the new tags(s) will be installed based on -s selection.

 Input : 
    -f tagsFile/or list of tag(s) (required) - a file or a commas separated list of tags 
    -c mgiinstalls Configuration file (required)
    -s servers type (optional) [test/prod/dmz] - default test
    -t target servers list (optional) [rohan,bhmgiapt01,...] -Where to install the tag(s)
    -l generates list of servers type (optional) where the product(s) will be installed
    -o Owner of the tag(s) - default mgiadmin
    -r Install Request summary - default null
    -n Additional comments  - default null
    -j TR number  - default null
  
Note: the script does the following:
  - Sources the Configuration file
  - loads manifest file into memory
  - generates a list of unique servers where to install new tag(s)
  - Calls the updateDistributeManifest script
  - Calls the mgiInstall.sh script 

Usage: ./Install.pl -f path2/product2install.tags -c {path2}/Configuration [-s prod] [-l] [-o mgiadmin] [-r ""] [-n ""][-j ""] 

Usage: ./Install.pl -f path2/product2install.tags -c {path2}/Configuration -s prod 
The above installs tags found product2install.tag file on production servers

Usage: ./Install.pl -f  exporter-5-1-9-4 -c {path2}/Configuration -s prod -l 
The above list production servers where the new exporter tag will be installed
Usage: ./Install.pl -f  exporter-5-1-9-4,mgidbutilities-5-2-0-5 -c {path2}/Configuration -l 

Usage: ./Install.pl -f  exporter-5-1-9-4 -c {path2}/Configuration -t mtdoom 
The above will install the exporter tag exporter-5-1-9-4 on mtdoom

HELP
exit(1);
}
#
# This funtion generates tree unique maps of servers. One for test , one for
# production, and one for dmz servers
# These maps will be used by subsequent functions
#
sub load_serverList{
 my($prodserverfile,$testservers_ref,$prodservers_ref)=@_;
 if(-f $prodserverfile){
   open(IN,"$prodserverfile");
   while(<IN>){
     $server=$_;
     next if($server=~/^#/);next if(!(length $server)); next if($server eq "");
     chomp($server);($server,$type)=split(",",$server);
     next if($server eq "");
     if($type=~/test_server/){
        ${$testservers_ref}{"$server"}=1;}
     else{
        ${$prodservers_ref}{"$server"}=1 ;}
   }close(IN);
 }
 else{print "$prodserverfile does not exist\n";}
}

#set manifest distribution base servers - where to run the distribute script from
%manifest_dist=();

$current_host=`uname -n`;
chomp($current_host);
$current_usr=$ENV{LOGNAME} || $ENV{USER} || getpwuid($<);
chomp($current_usr);

#
# This function sets a map of products/tags 
# and a list of unique test/prod/dmz servers
# where the new product tags should be installed
# Using the manifest and the servers list
#
sub loadProductServersList {
 ($manifest,$tagsFilename,$servers_ref,$tagsMap_ref,$targetServers_ref)=@_;
  #
  #load tags to install into a map of product/tag pairs
  #
  @tags=();
  if(-f $tagsFilename){
      open(TAG,"$tagsFilename") or die "Error opening $tagsFilename: $!\n";
      @tags=<TAG>;close(TAG);
  }else{@tags=split(",",$tagsFilename);}
  foreach $ptag(@tags){
          $pname=""; $tag="";
          next if($ptag=~/^#/);chomp($ptag);
          if($ptag=~/=/){($pname,$tag)=split(/=/,$ptag); }
          else{split(/-/,$ptag);$pname=@_[0];$tag=$ptag;} 
          $tag=~s/\s+//g;
          ${$tagsMap_ref}{"$pname"}=$tag;
          #print "Processing $pname=$tag\n";
  }
  
  open(IN,"$manifest")or die "Error opening $manifest: $!\n";
  # Set list of test/prod/dmz servers where these tags will be installed
  # assumption: every product line in the manifest contains 7 fields 
  while(<IN>){$line=$_;
     chomp($line); next if($line=~/^#/);
     @fields=split(/\|/,$line);next if(@fields<6);
     @servers=split(",",$fields[5]);$servs=$fields[5];$servs=~s/^\s+//;$servs=~s/\s+$//;
     $currentTag=$fields[0];@fields=split("-",$currentTag);
     $pname=(@fields>0)?$fields[0]:"";
     if($pname ne ""){
        if(exists(${$tagsMap_ref}{"$pname"})){
           if($servs=~/^All$/){
              %{$targetServers_ref}=%{$servers_ref};
           }
           else{
               foreach $server(@servers){
                   ${$targetServers_ref}{"$server"}=1 if(exists(${$servers_ref}{"$server"}));}
           }
  }}}
  #Check if there is mgiconfig or lib_py_misc tag in the list
  # If yes, then set targetServers=servers
  %{$targetServers_ref}=%{$servers_ref} if(exists(${$tagsMap_ref}{"mgiconfig"}));
}
#
#
##### Main prog ###################################################
$config_file=$opt_c; $tagfile=$opt_f;
$stype=($opt_s)?$opt_s:"test";$testserverfile="";
$prodserverfile="";$manifest="";$distribute_manifest="";
$manifest_prod="";$distribute_manifest_prod="";
$logdir="";$script_dir="";
$mgiinstall_script=""; 

#
#get global variables(servers file, manifest file) from config file
#
$logdir="";$script_dir="";
open(CONF,"$config_file") or die "$!\n";
while(<CONF>){
  chomp($_);($label,$filepath)=split("=",$_);
  $prodserverfile=$filepath if($label eq "SERVERLIST");
  $manifest=$filepath if($label eq "MANIFEST");
  $manifest_prod=$filepath if($label eq "MANIFEST_PROD");
  $logdir=$filepath if($label eq "LOG_DIR");
  $script_dir=$filepath if($label eq "SCRIPT_DIR");
  $distribute_manifest=$filepath if($label eq "DISTRIBMANIFEST");
  $distribute_manifest_prod=$filepath if($label eq "DISTRIBMANIFEST_PROD");
  $mgiinstall_script=$filepath if($label eq "MGIINSTALL_SCRIPT_NAME");
  
}close(CONF);
$is_prod=0;
if(lc($stype)=~/prod/){
  $is_prod=1;$manifest=$manifest_prod;
  $distribute_manifest=$distribute_manifest_prod;
}
$logfile="$logdir/Install.pl.log";
$tagslogfile="$logdir/tagsInstall.log";
#tagsInstall.log
open(LOG,">$logfile");
open(TAG,">>$tagslogfile");
#
# Initiate server lists and set target servers where to install new tags
#
%prodServers=();%testServers=();%tagsMap=();%targetServers=();
&load_serverList($prodserverfile,\%testServers,\%prodServers);

# Here I need to check if user specified target server(s) 
# Note: you should not provide a list of servers from different types 
# It should only provide either a list of test servers, production servers, or dmz servers
%servers=(lc($stype) eq "prod")?%prodServers:%servers;
%servers=(lc($stype) eq "test")?%testServers:%servers;

&loadProductServersList($manifest,$tagfile,\%servers,\%tagsMap,\%targetServers);
#$servers="";
$server_list=join(",",keys %targetServers);
print "List of targeted $stype servers:$server_list\n";
if($opt_t){$servers=$opt_t;}
else{$servers=join(",",keys %targetServers);}
$tags= join(",",values %tagsMap) or die "$!"; $products=join(",", keys %tagsMap);
print  LOG "The tags: $tags \nwill be installed on the following $stype servers:\n$servers\n";
print  "\n********\nTags: $tags \nTo install on $stype servers: $servers\n*******\n";

exit(0);
if($opt_l){ #user only want to list target servers
   $servers=~s/,/\n/g;
   print  "The tags: $tags \n will be installed on the following $stype servers:\n$servers\n";
}
else{ #user wants to run the install
    if($current_usr =~/mgiadmin/){ #only user mgiadmin can run MGI_install
       $cmd="$mgiinstall_script $stype $tags $servers";
       print LOG "Running $cmd\n";
       system($cmd);
       $datestring = localtime();
       ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
       $mon+=1; $year+=1900;
       $owner=$current_usr;$request=($opt_r)?$opt_r:"";$owner=($opt_o)?$opt_o:"";
       $tr=($opt_j)?$opt_j:"";$cmt=($opt_n)?$opt_n:"";
       $message="SERVERTYPE=$stype:;TAG=$tags:;OWNER=$owner:;REQUEST=$request:;";
       $message.="TR=$tr:;DATE=$mon/$mday/$year - $hour:$min:$sec:;COMMENT=$cmt\n";
       print TAG "$message";
   }
   else{
      print "$current_usr does not have permissions to run MGI Installs - Only mgiadmin can\n";
      print LOG "$current_usr does not have permissions to run MGI Installs - Only mgiadmin can\n";
   }
}
print LOG "Program Complete -- Current Host: $current_host and Current User: $current_usr\n";
print "Program Complete -- Current Host: $current_host and Current User: $current_usr\n";
system("chmod 777 $logdir/Install.pl.log") if($current_usr=~/mgiadmin/);
close(LOG);

exit(0);


