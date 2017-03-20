#!/bin/sh

#This script exports tags from both public and private repositories
#
# Assumption:
#    1) User has credentials to connect to the private repo
#    2) User has generated personal token key (GTOKEN) for their github account
#    3) User has added GTOKEN environment variable to their .cshrc or .bashrc file
#
# Input:
#   1) Owner/Organization name
#   2) Repository name
#   3) Tag
#
# What it does:
#    1) Set path to git tag
#    2) wget private tag using GTOKEN authentication
#    3) Create local directory for the new tag
#    4) Untar new tag tar 
#    5) Remove the downloaded tar file
#
# Author: lnh
# Date : 7/22/2016
#
#setup the log file
SCRIPT_NAME=`basename $0`
LOG=$SCRIPT_NAME.log
rm -f $LOG
touch $LOG

#Check the number of 
if [ $# -lt 3 ]
then
  echo ""
  echo "***********************************************"
  echo ""
  echo "Usage: ./$SCRIPT_NAME ORGANIZATION/OWNER REPO_NAME GIT_TAG"
  echo "Example1: ./$SCRIPT_NAME mgijax pgdbutilities  6-0-4-3"
  echo "Example1: ./$SCRIPT_NAME mgijax ei  master"
  echo ""
  echo "Assumption:
        1) User has credentials to connect to the private repo
        2) User has generated personal token key (GTOKEN) for their github account
        3) User has added GTOKEN environment variable to their .cshrc or .bashrc file
  "
  echo "***********************************************"
  echo ""
  exit 1
fi
##
ORG=$1
WGET=`which wget`
TAR=`which tar`
REPO=$2
TAG=$3

#Url to private repository
GIT_URL=https://api.github.com/repos/$ORG/$REPO/tarball/$TAG
#Local tag directory
TAG_DIR=$REPO-$TAG
#Results tar file
TAG_TAR_FILE=$TAG_DIR.tar.gz

date | tee -a $LOG
echo "wget path: $WGET" | tee -a $LOG
echo "tar path: $TAR"| tee -a $LOG
echo "Tag: $TAG"| tee -a $LOG
echo "Repository: $REPO"| tee -a $LOG
echo "Organization: $ORG"| tee -a $LOG
echo "Git url: $GIT_URL"| tee -a $LOG
echo "My Github personal token: $GTOKEN" | tee -a $LOG
date | tee -a $LOG

if [ "$GTOKEN" == "" ]
then
   echo "Your personal token used to authenticate to github is not set" | tee -a $LOG
   echo "You must first generate a valid personal token for your github account"| tee -a $LOG
   echo " and add it to your environment variables (in your .cshrc or .bashrc )"| tee -a $LOG
   exit 1
fi

#execute the commande 
echo Cammand: $WGET -O $TAG_TAR_FILE --header="Authorization: token $GTOKEN" "$GIT_URL" | tee -a $LOG
$WGET -O $TAG_TAR_FILE --header="Authorization: token $GTOKEN" "$GIT_URL" | tee -a $LOG

#clean previous download of this tag
if [ -d $TAG_DIR ]
then
  rm -rf $TAG_DIR
fi

#Create local directory for this tag
mkdir $TAG_DIR
#Untar the new archive
echo "Untar $TAG_TAR_FILE" | tee -a $LOG
echo "Command: $TAR -xzvf $TAG_TAR_FILE -C $TAG_DIR --strip-components 1"
$TAR -xzvf $TAG_TAR_FILE -C $TAG_DIR --strip-components 1

#Remove the tar file
rm -f $TAG_TAR_FILE

date
echo "Program complete"

