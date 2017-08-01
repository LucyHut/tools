<?php
require_once("server_types.php");
#
#Utility to handle servers

class Server extends ServerTypes{
      public $name;
      public $os;
      public $type;
      public $mounts;
      private $class_base;
      private $local_manifest;
      private $local_master_config;
     
      function __construct($name){
           $name=preg_replace("/\r\n|\r|\n/","",trim($name));
           $this->name=$name;
           $this->mounts=array();
           $this->local_manifest="$this->mgiconfig_dir/manifest";
           $this->local_master_config="$this->mgiconfig_dir/master.config.sh";
           $this->class_base=`pwd`;
           parent::__construct(); 
           if(array_key_exists($name,$this->servers_by_name)){
              $this->type=join(",",array_keys($this->servers_by_name{"$name"}));
           }else{$this->type="dev";}
           $this->getMount();
      } 
     function getMount(){
         $current_server=preg_replace("/\r\n|\r|\n/","",`uname -n`);
         $mounts=array();
         if($current_server==$this->name){
            #$mounts=`df -h | grep harlond`;
            $mounts=preg_split("/\n/",`df -h | grep harlond`,-1,PREG_SPLIT_NO_EMPTY);
            foreach($mounts as $mount){
              list($file_system,$size,$used,$available,$percent_used,$local_mount)=preg_split("/\s+/",$mount);
              if(preg_match("/\/home/",$local_mount))continue;
              $this->mounts{"$local_mount"}="$file_system:$size,$percent_used";
            }
         }else{
              print "The target server ($this->name) is a remote server\n";
          }
     }
}
?>
