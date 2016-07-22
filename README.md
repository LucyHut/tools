# Tools
Public repo to share some of my scripts

##Script: gitExportRepoTag.sh

This script exports tags from both public and private repositories

#### Assumption:

    1) User has credentials to connect to the private repo
    2) User has generated personal token key (GTOKEN) for their github account
    3) User has added GTOKEN environment variable to their .cshrc or .bashrc file

#### Input:

    1) Owner/Organization name
    2) Repository name
    3) Tag

#### What it does:

    1) Set path to git tag
    2) wget private tag using GTOKEN authentication
    3) Create local directory for the new tag
    4) Untar new tag tar 
    5) Remove the downloaded tar file


