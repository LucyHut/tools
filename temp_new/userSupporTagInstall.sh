#!/bin/bash

#this script installs mgihome,userhelp,faq tags
if [ $# -ne 2 ]
then
  echo "Usage : ./program product_name product_tag"
  echo "Example1 : ./mgihomeinstall.sh mgihome mgihome-6-0-3-0"
  echo "Example2 : ./mgihomeinstall.sh userhelp userhelp-6-0-3-0"
  echo "Example3 : ./mgihomeinstall.sh faq faq-6-0-3-0"
  echo "Example4 : ./mgihomeinstall.sh silverbook silverbook-6-0-3-1"
  exit 1
fi
base_dir=`dirname $0`
cd `dirname $0`

echo "Base directory is $base_dir"
if [ -f ../Configuration ]
then
    . ../Configuration
else
   echo "Configuration file is missing"
   exit 1
fi
#
# python config is only used for silverbook product install
#
python_config=$USER_LIVE/lib/python/Configuration.py

cd $USER_LIVE
product_name=$1
product_tag=$2
server_name=`uname -n`
TARGET="bhmgipub01lt bhmgipub01lp"
echo "mgilive: $USER_LIVE"
echo "product to install: $product_name"
echo "product_tag: $product_tag"
echo "Target servers: $TARGET"
echo "current_server: $server_name"
echo "Python configuration file: $python_config"
#Check if the current server is the host server for this product
#
is_target=0

for target_server in $TARGET
do
    if [ "$server_name" = $target_server ]
    then
       is_target=1
    fi
done

if [ $is_target -ne 1 ]
then
   echo "$server_name is not one of the designated servers for $product_name installs"
   exit 1
fi
#
# Check if the tag directory exists
#
if [ ! -d $product_tag ]
then
   echo "Exporting tag $product_tag from the source control"
   #Check if tag exists in cvs
   #cvstag=`cvs status -v $product_name | grep $product_tag`
   #
   #cvs export this tag
   echo "cvs export -r $product_tag -d $product_tag $product_name"
   cvs export -r $product_tag -d $product_tag $product_name
   #
   # git export 
   #wget ${GITHUB_URL}/${product_name}/archive/${tag_num}.tar.gz -O ${product_tag}.tar.gz"

fi
# Check if the tag was exported
if [ ! -d $product_tag ]
then
   echo "Directory $product_tag does not exist on the server ($server_name)"
   echo "Failed to export tag $product_tag from the source control"
   exit 1
fi
#
#Check if the last mofified date of the Configuration.default is older
# than that of the current Configuration
#
cconfig_file="$product_name/Configuration"
tconfig_file="$product_tag/Configuration.defaults"
if [ ! -f $tconfig_file ]
then
    echo "$tconfig_file file does not exist - check that $product_tag exists in cvs"  
    rm -rf $product_tag
    exit 1
fi
#get the symbolic tag
#
symlink_tag=`ls  -l "$product_name" | cut -d'>' -f2`
echo "The current tag is $symlink_tag"
#remove leading iand trailing whitespaces
#
symlink_tag="$(echo -e "${symlink_tag}" | sed -e 's/^[[:space:]]*//')"
symlink_tag="$(echo -e "${symlink_tag}" | sed -e 's/[[:space:]]*$//')"

if [ "$product_tag" != "$symlink_tag" ]
then
    echo "The current tag is $symlink_tag and the new tag is $product_tag"
else
    echo "$product_tag is the current tag installed on $server_name"
    echo "Program complete"
    exit 0
fi
#
# Check
if [ -f $cconfig_file ]
then
    cconfig_file_mod_date=` stat -c%y $cconfig_file | cut -d " " -f1 | sed s/-/_/g|cut -d "_" -f"1-3"`
    tconfig_file_mod_date=` stat -c%y $tconfig_file | cut -d " " -f1 | sed s/-/_/g|cut -d "_" -f"1-3"`
    echo "$cconfig_file was last modified $cconfig_file_mod_date"
    echo "$tconfig_file was last modified $tconfig_file_mod_date"
    #update the configuration file
    if [ "$tconfig_file" -ot "$cconfig_file" ]; then
        echo "cp $cconfig_file $product_tag/ "
        cp $cconfig_file $product_tag/
    else
        echo "cp $tconfig_file $product_tag/Configuration "
        cp $tconfig_file $product_tag/Configuration
    fi
    echo "rm $product_name "
    rm $product_name 
fi
#
# Create the symbolic link for this product
#
echo "ln -s $product_tag $product_name" 
ln -s $product_tag $product_name 
cd $product_name 
working_dir=`pwd`
echo "Working directory is $working_dir"
if [ "$product_name" = silverbook ]
then
    echo "./Install $python_config"
    ./Install $python_config 2>&1
else
   echo "./Install"
   ./Install 2>&1
fi
echo "Program complete"
exit 0


