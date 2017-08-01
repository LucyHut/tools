<?php
#
#Global Utility to index the list of servers maintained
# by SE admin - Two indexes are created:
#
# 1) servers by name: {name}{type}=1
# 2) servers by type: {type}{name}=1
#
class ServerTypes{
      private $prod_serverList; #Current list of production/public servers
      private $test_serverList; #Current list of test servers
      private $dev_serverList; #Current list of dev servers
  
      public $mgiconfig_dir;   #path to mgiconfig 
      public $servers_by_name;  # Index servers by name
      public $servers_by_type;  # Index servers by type
   
      function __construct(){
           $this->mgiconfig_dir="/usr/local/mgi/live/mgiconfig";
           $this->prod_serverList=$this->mgiconfig_dir."/bin/serverList";
           $this->test_serverList=$this->mgiconfig_dir."/bin/serverList_Test";
           $this->dev_serverList="/mgi/centrallog/xmls/dev_servers.xml";
           $this->servers_by_name=array();
           $this->servers_by_type=array();
           $this->load_servers();
      }
      //index list pf servers maintained by SE admin
      function load_servers(){
          #load production/public servers
          if(file_exists($this->prod_serverList)){
             $lines=array();$lines=file($this->prod_serverList);
             if(is_array($lines)){
                foreach($lines as $line_num=>$line){
                        $line=preg_replace("/\r\n|\r|\n/","",trim($line));
                        if(preg_match("/#/",$line))continue;
                        list($type,$name)=explode(",",$line);
                        $type=($type=="build")?"dmz":"prod";
                        $this->servers_by_name{"$name"}{"$type"}=1;
                        $this->servers_by_type{"$type"}{"$name"}=1;
         }}} 
         #load test servers
          if(file_exists($this->test_serverList)){
            $type="test";
             $lines=array();$lines=file($this->test_serverList);
             if(is_array($lines)){
                foreach($lines as $line_num=>$line){
                        if(preg_match("/#/",$line))continue;
                        $name=preg_replace("/\r\n|\r|\n/","",trim($line));
                        $this->servers_by_name{"$name"}{"$type"}=1;
                        $this->servers_by_type{"$type"}{"$name"}=1;
         }}}  
         #load development servers
      }
}
?>

