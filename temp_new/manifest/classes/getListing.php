<?php
require_once("server.php");
require_once("product.php");
//sproduct - prod -[serv1:0,server:1,...],test-
echo json_encode(array('products'=>$items_list));
?>
