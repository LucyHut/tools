#!/bin/sh

if [ $# -lt 2 ]
then
   echo ""
   echo "***************************************************"
   echo "Usage : ./getServerSoft.sh type commasSeparatedListOfServers"
   echo "       To generate system information of each server in serverList"
   echo ""
   echo "OR"
   echo ""
   echo "Usage : ./getServerSoft.sh path commasSeparatedListOfServers commasSeparatedListOfSoftwares"
   echo "       To generate software path on  each server in serverList"
   echo ""
   echo "***************************************************"

   exit 1
fi
if [ "$1" = type ] 
then
  echo "Generating Servers types "
elif [ "$1" = path ]
then
   echo "Generating Software Path"
else
  echo "Bad first argument '$1'. It should be 'type' or 'path'"
  exit 1
fi

echo "valid $1 option"
IFS=', ' read -a servers <<< "$2"

if [ "$1" = type ]
then 
  echo "nodename: kernel-name kernel-release kernel-version machine processor operating-sytem"
  for server in "${servers[@]}"
  do
     server_info=`ssh -q $server uname -srmpo `
     server_type=`echo $server_info`  
     echo "$server: $server_info"      
  done
else
  echo "nodename: software,softwareInstallPath"
  IFS=', ' read -a softwarelist <<< "$3"
  for server in "${servers[@]}"
  do
      for software in "${softwarelist[@]}"
      do
         softwarepath=`ssh -q $server which $software`
         if echo "$softwarepath" | grep "not found">/dev/null; then
             softwarepath="Not Installed"
         fi
         echo "$server: $software,$softwarepath" 
      done
  done
fi
exit 0
