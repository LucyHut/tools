#!/usr/bin/env perl

#
# Author : lnh - 07/2014
# 
use vars qw ($opt_h $opt_f $opt_s $opt_c);
use Getopt::Std;
getopts('hf:s:c:');

if(($opt_h)||(!$opt_c)||!($opt_f)){
 print <<HELP;
This script update and distribute the manifest

 Input : 
   1. -f tagsFile (required) 
   2. -s servers type (-s prod  -> for prod/pub servers, -s test -> for test servers)
       optional,default test servers
   3. -c configfile (required)

Note: the script does the following:
  - Source the Configuration file
  - load manifest file into memory
  - update products in the manifest with new tags (temp file)
  - save manifest as manifest.old
  - rename temp file to manifest

Usage: ./updateDistribManifest.pl [-s test] -f /path2/products2intsall.tags -c  /path2/Configuration 

HELP
exit(1);
}
#
#Get current user
#
$current_host=`uname -n`;
chomp($current_host);
$current_usr=$ENV{LOGNAME} || $ENV{USER} || getpwuid($<);
chomp($current_usr);
if(!($current_usr =~/mgiadmin/)){ #only user mgiadmin can run MGI_install
      print "Upate and Distribute Manifest failed. $current_usr does not have permissions to run MGI Installs - Only mgiadmin can\n";
      exit(1);
 }

#
# update manifest file with new tags
#
sub updateManifest {
 ($manifest,$tagsFilename)=@_; @tags=();%tagsMap=();
  $logs="";
  if(-f $tagsFilename){
      open(TAG,"$tagsFilename") or die "Error opening $tagsFilename: $!\n";
      @tags=<TAG>;close(TAG);
  }else{@tags=split(",",$tagsFilename);}
  #Load product/tag map
  foreach $ptag(@tags){
          next if($ptag=~/^#/);chomp($ptag);
          $pname="";$tag="";
          if($ptag=~/=/){($pname,$tag)=split("=",$ptag); }
          else{@pducts=split("-",$ptag);$pname=$pducts[0];$tag=$ptag;}
          $tagsMap{"$pname-"}=$tag;
  }
  open(OUT,">$manifest.temp")or die "Error opening $manifest.temp: $!\n";
  open(IN,"$manifest")or die "Error opening $manifest: $!\n";
  while(<IN>){$line=$_;
     chomp($line);
     if($line=~/^#/){print OUT "$line\n";next;}
     @tags=split(/\|/,$line);$currentTag=$tags[0];
     @product=split("-",$currentTag);
     $pname=$product[0];
     $newTag=$tagsMap{"$pname-"};
     if(exists($tagsMap{"$pname-"})){
        $line=~s/^$currentTag/$newTag/;
        $logs.="UPDAting current tag $currentTag to $newTag\n";}
     print OUT "$line\n";
  }
  system("mv $manifest $manifest.old");
  system("mv $manifest.temp $manifest");
  system("chmod g+r $manifest");
  return $logs;
}
##### Main prog
$config_file=$opt_c; $tagfile=$opt_f;
$stype=($opt_s)?$opt_s:"test";
$prodserverfile="";

$manifest="";$distribute_manifest="";
$manifest_prod="";$distribute_manifest_prod="";
#set manifest distribution base servers - where to run the distribute script from
%manifest_dist=();
#these default setting will be overwritten by the Configuration file settings
#
$manifest_dist{"test"}="mgidevapp.jax.org";
$manifest_dist{"prod"}="mgiprodapp.jax.org";
#
#get global variables(servers file, manifest file) from config file
#
$logdir="";
open(CONF,"$config_file") or die "$!\n";
while(<CONF>){
  chomp($_);($label,$filepath)=split("=",$_);
 $prodserverfile=$filepath if($label eq "SERVERLIST");
 $manifest=$filepath if($label eq "MANIFEST");
 $manifest_prod=$filepath if($label eq "MANIFEST_PROD");
 $logdir=$filepath if($label eq "LOG_DIR");
 $distribute_manifest=$filepath if($label eq "DISTRIBMANIFEST");
 $distribute_manifest_prod=$filepath if($label eq "DISTRIBMANIFEST_PROD");
 $manifest_dist{"test"}=$filepath if($label eq "MANIFEST_TEST_SERVER");
 $manifest_dist{"prod"}=$filepath if($label eq "MANIFEST_PROD_SERVER");

 
}close(CONF);
if(lc($stype) eq "prod"){$manifest=$manifest_prod;$distribute_manifest=$distribute_manifest_prod;}
#Run the distribute from the designated test or prod server 
$ssh_server=($opt_s eq "test")?$manifest_dist{"test"}:$manifest_dist{"prod"};
$current_host=~s/\s+//g;

open(LOG,">$logdir/updateDistribManifest.pl.log");
if(($current_host=~/$ssh_server/)){ #only runs from designated servers
    print LOG "Updating manifest $manifest on $current_host\n";
    $logs=&updateManifest($manifest,$tagfile);
    print LOG "$logs"; 
    print  LOG "Running $distribute_manifest on $stype servers from $current_host\n";
    `$distribute_manifest >>$LOG  2&1 `;
}
else{
    print  LOG "The manifest was not updated - The script was invoqed from - $current_host. To update and distribute \n";
    print LOG "the manifest for $opt_s servers, you should run the script from $ssh_server\n";
 }
print LOG "Program Complete\n";
close(LOG);
system("chmod 664 $logdir/updateDistribManifest.pl.log");
exit(0);


