## Steps to mount S3 file system on local server
### Install s3fs  either:
See:  https://github.com/s3fs-fuse/s3fs-fuse

On RHEL/CentOS 7 and newer through EPEL repositories:
- sudo yum install epel-release 
- sudo yum install s3fs-fuse

Or 

Install from build:
- sudo yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel 
- git clone https://github.com/s3fs-fuse/s3fs-fuse.git 
- cd s3fs-fuse 
- sudo ./autogen.sh 
- sudo ./configure --prefix=/usr --with-openssl 
- sudo make 
- sudo make install 
- which s3fs 
- sudo touch /etc/passwd-s3fs 
- sudo vim /etc/passwd-s3fs (then enter aws user_accesskey:awsuser_secretkey) 
- sudo chmod 640 /etc/passwd-s3fs


## On EC2 Instances
#
## EFS cmd
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport  fs-9cfe74d4.efs.us-east-1.amazonaws.com:/ /data
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport  fs-56fe741e.efs.us-east-1.amazonaws.com:/ /mnt/transformed
## S3fsi cmd line 
sudo s3fs biocore-data  -o passwd_file=/etc/passwd-s3fs -o uid=500 -o gid=1001 -o mp_umask=002 -o allow_other -o use_cache=/tmp  -o multireq_max=20 /data
sudo s3fs biocore-software  -o passwd_file=/etc/passwd-s3fs -o uid=500 -o gid=1001 -o mp_umask=002 -o allow_other -o use_cache=/tmp  -o multireq_max=20 /opt/software


##### The fstab file
#EFS 
fs-9cfe74d4.efs.us-east-1.amazonaws.com:/       /data    nfs     nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport       0       0
fs-3cda4f74.efs.us-east-1.amazonaws.com:/       /opt/software   nfs     nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport       0       0

## S3 
s3fs#biocore-data   /data   fuse    allow_other,use_cache=/tmp/cache,umask=0002,uid=500,gid=1001       0       0
s3fs#biocore-software   /opt/software   fuse    allow_other,use_cache=/tmp/cache,umask=0002,uid=500,gid=1001       0       0

