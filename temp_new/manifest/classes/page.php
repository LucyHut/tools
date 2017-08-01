<?php

class Page extends Manifest{
      function __construct(){
      parent::__construct();}
      function getHeader(){
         $header="<!DOCTYPE html>\n";
         $header.="<html><head>\n";
         $header.="<meta charset=\"UTF-8\">
                   <title>Manifest Browser</title>\n
                   \n<meta name=\"description\" content=\"Web tool to browse the manifest\">
                   <meta name=\"keywords\" content=\"manifest browser\">";
         $header.="<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">";
         $header.="</head>";
      }
      function getFormBock($type){
         $form="<form name='manifest' action=''>";
         $form="<div id='stype'>".$this->getServerTypes($type)."</div>";
         $form="<div id='server'>".$this->getServer_list($type)."</div>";
         $form.="</form>";
         return $form;
      }
      function getServerTypes($type){
          $options="";
          foreach(array_keys($this->servers_by_type) as $server_type){
                if($type==$server_type){
                   $options.="<input type='radio' name='stype' value='$server_type' checked/>$server_type<br/>\n";
                }else $options.="<input type='radio' name='stype' value='$server_type'/>$server_type<br/>\n";
          }
        return $options;
      }
      function getServer_list($type){
          $options="";
          $row=""; $count=0;
          foreach(array_keys($this->servers_by_type["$type"]) as $server){
               $row.="<li><input type='checkbox' name='server' value='$server' checked/>$server</li>\n";
               ++$count;
               if($count%6==0){$options.="<ul class='server'>$row</ul>\n";$row="";}
          }
          if(!empty($row))$options.="<ul class='server'>$row</ul>\n";
          return $options;
         
      } 
      //returns json string of products by server type
      //Product:tag / list of servers
      function getSeverProdGrid($type,$server){
              ksort($this->servers_by_type{"$type"});
              $servers=array_keys($this->servers_by_type{"$type"});
              $server_index_map=array();
              foreach($servers as $index=>$server_name){
                  print "[$index]\t$server_name\n";
                  $server_index_map{"$server_name"}=$index;
              }
              $products=array();
              $products{"servers"}=$servers;
              $this->getProductsByServerType($type,$products);
              ksort($products);
              foreach($products as $product=>$server_list){
                  $products{"$product"}=array();
                  print "$product\t".join(",",array_keys($server_list))."\n";
              }
      } 
}
?>
