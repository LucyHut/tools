<?php
 require_once("manifest.php");
#
#
#Utility to handle objects of type MGI product
#

class Product extends Manifest{
    public $name;
    public $prod_latest_tag;
    public $test_latest_tag;
    public $from_git; #This field contains a "C" or "G" to indicate whether the product
                            #should be retrieved from CVS or GitHub.
    public $install_dir;
    public $run_install;    #This field contains a "Y" or "N" to indicate whether the Install
                            #script for the product/tag should be run after it is checked out or exported.
    public $has_symbolic_link;  #This field contains a "Y" or "N" to indicate whether a symbolic
                                #link with the same name as the product should be created to
                                #point to the new product directory.
    public $test_servers;
    public $prod_servers;
    public $dmz_servers;
    function __construct($product){
         parent::__construct();
         $this->name=$product;
         $this->test_servers=$this->getTestServers($product);
         $this->prod_servers=$this->getProdServers($product);
         $this->dmz_servers=$this->getDmzServers($product);

         $this->prod_latest_tag=$this->getProdTag($product);
         $this->prod_latest_tag=$this->getProdTag($product);

         $this->prod_latest_tag=$this->getProdTag($product);
         $this->test_latest_tag=$this->getTestTag($product);

         $this->install_dir=$this->getInstallPath($product);
         $this->from_git=$this->inGit($product);
         $this->has_symbolic_link=$this->hasSymLink($product);
    }
    //Check if current server is one of the product hosts
    //CD to the install directory
    // Collects all python scripts
    // Parses each script for depends
    function getPythonDepends(){

    }
}
?>
