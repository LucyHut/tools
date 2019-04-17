
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

