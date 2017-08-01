from os.path import isfile
import xml.etree.ElementTree as ET

class XmlDOM:
    def __init__(self,token_file):
        self.doc_root=None
        self.setXmlDocRoot(token_file)

    def setXmlDocRoot(self,token_file):
        if isfile(token_file):
           try:
               xml_doc=ET.parse(token_file)
               if xml_doc:self.doc_root=xml_doc.getroot()
           except:
               pass
~                      
