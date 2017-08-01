#!/bin/env python

#This script gets the tally
#of the number of documents per index
#From both the active and inactive Solr servers
# It then generates a grid

import sys,os
#import xml.etree.ElementTree as xtree
from xml.dom import minidom as xtree
#https://hg.python.org/cpython/file/2.7/Lib/xml/dom/minidom.py
from datetime import datetime

#Setup path to data
xml_base="/mgi/centrallog/xmls"
active_public_file=xml_base+"/active-public.xml"
solr_inxdexes_file=xml_base+"/fe_solr_docs_tally.xml"

def generateGrid():
    xml_doc=xtree.parse(active_public_file)
    for server in xml_doc.getElementsByTagName("servers"):
        #for (name,value) in server.attributes.items():
        print server.getAttribute("name")," -- ",server.getAttribute("id")
def main():
    if os.path.isfile(active_public_file):
        print "Hello"
        generateGrid()

if __name__ == "__main__":
    today=datetime.now()
    print today.strftime("%Y/%m/%d %I:%M:%S %P")
    main()
    print solr_inxdexes_file, " generated"  
