#!/usr/bin/env python

import os, sys
from os.path import isfile,isdir,join
 
import datetime
import server_types
import global_config
#
# This class loads and parses production manifest
# into data containers 
#
class Manifest(server_types.ServerTypes):
     prod_manifest_file;
     test_manifest_file;
   
     public  $prod_manifest_map; 
     public  $test_manifest_map; 

     public  $server_product_map;

     private $test_server;
     private $prod_server;
     private $mgiadmin_home;
     function __construct(){
            $this->mgiadmin_home="/home/mgiadmin";        
            $this->prod_manifest="$this->mgiadmin_home/manifest";
            $this->prod_manifest_map=array();
            $this->test_manifest_map=array();
            $this->server_product_map=array();
 
            $this->test_server="bhmgidevapp01";
            $this->prod_server="bhmgiapp01";
            parent::__construct();
            $lines=array();$lines=file($this->prod_manifest);
            $this->loadManifest($lines,$this->prod_manifest_map);
            $this->test_manifest=$this->mgiconfig_dir."/manifest";
            $lines=array(); $user="lnh"; $temp_manifest="temp.log";
            `ssh -q $user@$this->test_server cat $this->test_manifest > $temp_manifest`;
            if(file_exists($temp_manifest)){
               $lines=file($temp_manifest);
               $this->loadManifest($lines,$this->test_manifest_map);
               `rm -f $temp_manifest`;
            }

     } 
     //loads manifest into a map
     //
     function loadManifest($lines,&$container){
             if(is_array($lines)){
                foreach($lines as $line_num=>$line){
                        $line=preg_replace("/\r\n|\r|\n/","",trim($line));
                        if(preg_match("/#/",$line))continue;
                        if(count(preg_split("/\|/",$line))<7){print "$line\n";continue;}
                        list($product_tag,$src_control,$path,$install,$symlink,$arg,$servers)=preg_split("/\|/",$line);
                        if(!$servers)continue;
                        list($product,$v1,$v2,$v3,$v4)=explode("-",$product_tag);
                        $container{"$product"}{"tag"}="$product_tag";
                        $container{"$product"}{"servers"}="$servers";
                        $container{"$product"}{"path"}="$path";
                        $container{"$product"}{"cvs"}="$src_control";
                        $container{"$product"}{"line"}="$line";
                        $container{"$product"}{"link"}="$symlink";
                        $serv_list=explode(",",$servers);
                        foreach($serv_list as $server){$this->server_product_map{"$server"}{"$product"}=$path;}
            }}
     }
    //return list of products installed on the specified server type
    function getProductsByServerType($type,&$products){
           $products=array();
           $servers=array_keys($this->servers_by_type{"$type"});
           foreach($servers as $server){
                $p_list=$this->getProducts($server);
                if(!empty($p_list)){
                   foreach($p_list as $product){$products{"$product"}{"$server"}=1;}
                }
           }
    }
    //return list of products installed on this server
    //
     function getProducts($server){
         $products=array();
         if(array_key_exists($server,$this->server_product_map)){
           return array_keys($this->server_product_map{"$server"});
         }
         else return $products;
     }
     //return the install path of this product
     function getInstallPath($product){
         if(array_key_exists($product,$this->prod_manifest_map))
            return $this->prod_manifest_map{$product}{"path"};
         else return "";
     }
     //returns the flag to indicate whether or not the product is in github
     function inGit($product){
         if(array_key_exists($product,$this->prod_manifest_map))
            return $this->prod_manifest_map{$product}{"cvs"};
         else return "";
     }
     //returns the flag to indicate whether or not the product has a symbolic link
     function hasSymLink($product){
         if(array_key_exists($product,$this->prod_manifest_map))
            return $this->prod_manifest_map{$product}{"link"};
         else return "";
     }
     function getTestTag($product){
         if(array_key_exists($product,$this->test_manifest_map))
            return $this->test_manifest_map{$product}{"tag"};
         else return "";
     }
     function getProdTag($product){
         if(array_key_exists($product,$this->prod_manifest_map))
            return $this->prod_manifest_map{$product}{"tag"};
         else return "";
     }
     //Return a commas separated list of all the servers where the product is installed 
     function getServers($product){
          $product=strtolower($product);
          if(array_key_exists($product,$this->prod_manifest_map))
             return $prod_manifest_map{"$product"}{"servers"};
          elseif(array_key_exists($product,$this->test_manifest_map))
             return $test_manifest_map{"$product"}{"servers"};
          else return "";
     }
    //Return a commas separated list of test servers where the product is installed 
     function getTestServers($product){
          $product=strtolower($product);
          if(array_key_exists($product,$this->test_manifest_map)){
             $servers=explode(",",$this->test_manifest_map{"$product"}{"servers"});
             $test_servers=array();
             foreach($servers as $server){
                  if(array_key_exists($server,$this->servers_by_type{"test"}))$test_servers{"$server"}=1;
             }
             return join(",",array_keys($test_servers));
          }
          else return "";
     }
    //Return a commas separated list of prod servers where the product is installed 
     function getProdServers($product){
          $product=strtolower($product);
          if(array_key_exists($product,$this->prod_manifest_map)){
             $servers=explode(",",$this->prod_manifest_map{"$product"}{"servers"});
             $prod_servers=array();
             foreach($servers as $server){
                  if(array_key_exists($server,$this->servers_by_type{"prod"})){
                     if(array_key_exists($server,$this->servers_by_type{"dmz"}))continue;
                     $prod_servers{"$server"}=1;
                  }
             }
             return join(",",array_keys($prod_servers));
          }
          else return "";
     }
    //Return a commas separated list of dmz servers where the product is installed 
     function getDmzServers($product){
          $product=strtolower($product);
          if(array_key_exists($product,$this->prod_manifest_map)){
             $servers=explode(",",$this->prod_manifest_map{"$product"}{"servers"});
             $prod_servers=array();
             foreach($servers as $server){
                  if(array_key_exists($server,$this->servers_by_type{"dmz"})){
                     $prod_servers{"$server"}=1;
                  }
             }
             return join(",",array_keys($prod_servers));
          }
          else return "";
     }
}
?>
