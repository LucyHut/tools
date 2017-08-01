<?php
require_once("server.php");
require_once("product.php");
require_once("page.php");

$name=`uname -n`;
/*
$name="bhmgiweb14ld";
$name="gondor";
*/
$name="mgi-prodapp2";
$server= new Server($name);
$page= new Page;
print "Target Server Name:$name - Type:$server->type\n";

//$server->getMount();
foreach($server->mounts as $mount=>$file_system){
    print "$mount\t$file_system\n";
}

$product="fedatamodel";
$target_product= new Product($product);
/*$servers=$manifest->getProdServers($product);
$dmz_servers=$manifest->getDmzServers($product);
$test_servers=$manifest->getTestServers($product);
*/
$servers=$target_product->prod_servers;
$dmz_servers=$target_product->dmz_servers;
$test_servers=$target_product->test_servers;
$prod_tag=$target_product->prod_latest_tag;
$test_tag=$target_product->test_latest_tag;
/*
print"=============\nThe $product:$prod_tag is installed on production servers:$servers\n";
print"=============\nThe $product:$prod_tag  is installed on Dmz servers:$dmz_servers\n";
print"=============\nThe $product:$test_tag  is installed on Test servers:$test_servers\n";
*/
$type="prod";
ksort($server->servers_by_type{"$type"});
if(!empty($server->servers_by_type{"$type"})){
    $servers=array_keys($server->servers_by_type{"$type"});
   foreach($servers as $index=>$server_name){
         print "\n\n*************\nList of software installed on $server_name:\n";
         print join("\n",$target_product->getProducts($server_name));
   }
}
$type="test";
print "\n\n=========== $type servers ===========\n";
$page->getSeverProdGrid($type,"");
?>
