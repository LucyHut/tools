import getopt, sys 
from os.path import isfile

class ServerCat:
    def __init__(self,servers_file):
        self.test_servers=[]
        self.production_servers=[]

    def set_servers():


class ManifestLine:
    def __init__(self,line,server_cat):
        self.product_name=""         #Product name
        self.product_tag=""          #tag or branch
        self.install_path=""         #Install directory
        self.run_install_script=""   #Specifies whether or not
                                     # to run the install script default N
        self.has_symbolic_link=""    # Specifies whether or not to create a sym link
                                     # after the install
        self.special_arguments=""    #special argument to the install script if any
        self.servers=[]              # list of servers
    
    def setLine(self,line):
        if line is not None and "|" in line:
            line_fields=line.split("|")

class ManifestDOM:
    def __init__(self,server_cat):
        self.servers={}        #Stores servers with corresponding list
                               # of products
        self.porducts={}       #Stores list of product objects
        self.manifest_cat=server_cat     

    def loadServers():
    def loadProducts():

