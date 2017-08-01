<?php
require_once("server.php");
require_once("product.php");
require_once("page.php");

/*
*/
$page= new Page;

$server_type="prod";
$header=$page->getHeader();
$header.="<body><div class='section' id='form-block'>";
$header.=$page->getFormBock($server_type);
$header.="</div>";
//display default result (production/product grid)
//product - tag - cvs/git - server1,server2,...servern
// products are sorted by cvs/git then productname
$header.="<div class='section' id='result'>";
$header.=$page->getSeverProdGrid($server_type,$server);
$header.="</div>\n</body>\n</html>";
print $header;
exit(0);
?>
