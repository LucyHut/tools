#!/bin/env python

import sys, os
from datetime import datetime
from xml.dom import minidom

################################################
## This script displays current
#  active public and robot servers information
#  1) fe solr instance
#  2) fe fewi server 
#  3) fe database server
#  4) serachtool instance
#  5) SNP solr instance 
#
# The program also stores the above info in an xml file
# (active-public.xml) under /mgi/centrallog/xmls/
# 
#Author: lnh
#Date: 7/2016
#
# Usage: ./genActiveServers.py
#
###############################################

inactive_server={"pub1":"false","pub2":"false"}
today= datetime.now()
central_log_base="/mgi/centrallog"
flag_base=central_log_base+"/flags/weeklypubupdates"
flag_file=flag_base+"/InactivePublic"
xmls_base=central_log_base+"/xmls"
public_xml=xmls_base+"/public.xml"
active_pub_xml_file=xmls_base+"/active-public.xml"

def main():
    print "****************************"
    print ""
    print "Date:",today.strftime("%Y/%m/%d %I:%M:%S")
    #Check if flag file exists
    if not os.path.isfile(flag_file):
       print flag_file,"Does not exist on this server"
       sys.exit(1)
    if not os.path.isfile(public_xml):
       print public_xml,"Does not exist on this server"
       sys.exit(1)
    #Set inactive server
    flag=open(flag_file)
    server=flag.readline().strip()
    if server  not in inactive_server: 
       print "Invalid server flag: ", server, " in ",flag_file
       sys.exit(1)
    inactive_server[server]="true"
    active_server=""
    for server in inactive_server:
        if "false" in inactive_server[server]:active_server=server
    print " "
    print "Active public server this week:",active_server
    #get active server info
    xmldoc=minidom.parse(public_xml)
    pub_serv_list=xmldoc.getElementsByTagName("servers")
    for servers in pub_serv_list:
        if active_server in servers.getAttribute("id"):
           activefh=open(active_pub_xml_file,'w')
           activefh.write("<?xml version='1.0' encoding='utf-8'?>\n")
           activefh.write("<public>\n    <title>Active Public and Robot Servers</title>")
           activefh.write("\n    <date>%s</date>"%(today.strftime("%Y/%m/%d %I:%M:%S")))
           for server in servers.getElementsByTagName("server"):
               print "*************** "
               print server.getAttribute("name")
               activefh.write("\n    <servers name='%s'>\n"%(server.getAttribute("name")))
               print "--------------- "
               for tag in server.getElementsByTagName("tag"):
                   print "%s: %s"%(tag.getAttribute("name"),tag.childNodes[0].data.strip()) 
                   activefh.write("        <tag name='%s'> %s</tag>\n"%(tag.getAttribute("name"),tag.childNodes[0].data.strip())) 
               print " "
               activefh.write("    </servers>\n")
           activefh.write("</public>")
           activefh.close()
    print "****************************"

if __name__ == "__main__":
    main()
    print "Program complete"
    sys.exit(0)
