#!/bin/sh
#
#  
###########################################################################
#
#  Purpose:  This script will run the MGI_Install script 
#            to install tags on a given list of remote servers.
#
#            Note: This is only intended for non-DMZ servers.
#
#  Usage: program_name Server_type tags(commas separated) serverlist(commas separated)
#
#
#
#  Inputs: server_type, tags, servers
#  Outputs:  None
#
#  Exit Codes:
#
#      0:  Successful completion
#      1:  Fatal error occurred
#
#  Assumes:  Nothing
#

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

SCRIPT_NAME=`basename $0`
manifest_server=${MANIFEST_TEST_SERVER}
config_file=${PINSTALL_BASE}/Configuration
update_manifest=${UPDATE_MANIFEST_SCRIPT_NAME}
INSTALL_SCRIPT=${MGICONFIG}/bin/MGI_Install
DMZ_INSTALL_SCRIPT=${MGICONFIG}/bin/DMZ_Install

LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}.log
rm -f ${LOG_FILE}
touch ${LOG_FILE}

env | ${LOG_FILE}

echo "$0" | tee -a  ${LOG_FILE}

date | tee -a ${LOG_FILE}
#Check number of arguments

#
# Make sure there is at least three arguments to the script.
#
if [ $# -lt 3 ]
then
    echo "Usage: $0 Server_type tags(commas separated) serverlist(commas separated)"
    exit 1
fi
#update and distribute the manifest
if [ "$1" = prod ]
then
   manifest_server=${MANIFEST_PROD_SERVER}
elif [ "$1" = dmz ]
then
   manifest_server=${MANIFEST_PROD_SERVER}
   INSTALL_SCRIPT=${DMZ_INSTALL_SCRIPT}
   echo "DMZ Installs are not supported yet." |tee -a ${LOG_FILE}
   exit 1
fi

echo "Updating and distributing the manifest on $manifest_server" | tee -a ${LOG_FILE}
stype=$1
ptags=$2
slist=$3

if [ "$ptags" = mgiconfig ]
then
  INSTALL_SCRIPT="cd ${MGICONFIG};cvs update"
else
  echo "ssh mgiadmin@${manifest_server} ${update_manifest} -f $ptags -s $stype -c ${config_file}"
  ssh mgiadmin@${manifest_server} ${update_manifest} -f $ptags -s $stype -c ${config_file}
fi

date | tee -a ${LOG_FILE}
echo "backend install tags: $ptags on $stype servers: $slist" | tee -a ${LOG_FILE}
#
IFS=', ' read -a servers <<< "$3"
for server in "${servers[@]}"
do
    echo "*****************************" |tee -a ${LOG_FILE}
    echo "Starting Remote Installation on: $server" |tee -a ${LOG_FILE}
    echo "*****************************" |tee -a ${LOG_FILE}
    SLOG_FILE=${LOG_DIR}/${server}.log
    touch ${SLOG_FILE}
    # ssh mgiadmin@${server} ${MGICONFIG}/bin/MGI_Install -i | tee -a  ${SLOG_FILE} 
    date | tee -a ${SLOG_FILE}
    ssh mgiadmin@${server} ${INSTALL_SCRIPT} | tee -a  ${SLOG_FILE} 
    echo "Remote Installation For: $server Complete" |tee -a ${LOG_FILE}
    echo "-------------------------------------------------------" |tee -a ${LOG_FILE}

done

date | tee -a ${LOG_FILE}
echo "Program Complete"

exit 0
