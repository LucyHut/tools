#!/usr/bin/env perl

use vars qw ($opt_h $opt_p $opt_m);
use Getopt::Std;
getopts('hp:m:');
#
# Returns a list of python modules found 
# for a given python install
#
$pydoc="pydoc"; #python utility to check for modules
if(($opt_h)||(!$opt_p)){
   print "\n********************************************************************\n";
   print "Install path missing - You must provide a full path to pyton install directory.\n";
   print "Usage: ./getModulesList.pl -p full_path_to_python_install [ -m list_of_modules]\n";
   print "Where:\n-p   => full path to python install (required)\n";
   print "-m   => commas separated list of modules to check (optional) - By default the script list all\n";
   print "\nExamples:";
   print "\nTo list all the modules installed with python 2.4:  ./getModulesList.pl -p /usr/local/lib/python2.4/";
   print "\nTo check if libxml module is installed :  ./getModulesList.pl -p /usr/local/lib/python2.4/  -m libxml\n";
   print "\n********************************************************************\n";
   exit(1);
}
chdir $opt_p;
$path=`pwd`; chomp($path); $opt_p=~s/\/$//;
if($path ne "$opt_p"){
   print "ERROR:Current working directory ,$path not the same as target:$opt_p\n";
   exit(1);
}
if(!-f "$pydoc.py"){
   print "ERROR: $pydoc is not found under $path\n";
   exit(1);
}

print "Python Install Directory: $path\n";
@modules=`pydoc modules`;
%selected_modules=();
if($opt_m){
  @target_mods=split(",",$opt_m);
  foreach $module(@target_mods){$module=lc($module); $module=~s/^\s+//;$module=~s/\s+$//;
     $selected_modules{"$module"}=1;
  }
}
$all_mod="";
@module_list=();
foreach $module(@modules){ next if($module=~/ module | modules/);
  next if(!($module=~/\w+/));
  chomp($module);$module=~s/\(package\)//g;
  @mlist=split(/\s+/,$module);$count+=@mlist;
  foreach $mod(@mlist){ 
          if($opt_m){
             $token=lc($mod);$token=~s/^\s+//;$token=~s/\s+$//;
             if(exists($selected_modules{"$token"})){ push(@module_list,$mod);}
           }
           else{push(@module_list,$mod);}
   }
}
sort { lc($a) cmp lc($b) } @module_list;
print "Modules Count: $count\n";
print "Installed Modules:\n==\n".join("\n",@module_list)."\n==\n";
print "Program complete\n";
exit(0);
