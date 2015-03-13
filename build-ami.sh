#!/bin/sh

###############
# Prepare Files
###############
echo "###############"
echo "Prepare Files"
echo "###############"
sleep 3
PWD=`pwd`
mkdir /opt/teraproc
cp *.tmpl /opt/teraproc
cp lsb.* /opt/teraproc
cp lsf.cluster.openlava /opt/teraproc
cp configure*.sh /opt/teraproc
cp add-user.sh remove-user.sh /opt/teraproc
cp basic-batch.R /opt/teraproc
cp basic-rmpi.R /opt/teraproc
cp ldap.conf nsswitch.conf /opt/teraproc
cp ldapscripts.conf ldapadduser.template ldapaddgroup.template /opt/teraproc
cp fstab /opt/teraproc

###############
# Install openmpi
###############
echo "###############"
echo "Install openmpi"
echo "###############"
sleep 3
apt-get install -y libibnetdisc-dev
#wget https://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.4.tar.gz
#tar xvf openmpi-1.8.4.tar.gz
#cd openmpi-1.8.4/
#./configure --prefix=/usr/local/openmpi-1.8.4
#make
#sudo make install
tar xvf openmpi-1.8.4.tgz
mv openmpi-1.8.4 /usr/local
ln -s /usr/local/openmpi-1.8.4 /usr/local/openmpi
cp openmpi.sh /etc/profile.d

###############
# Install R
###############
echo "###############"
echo "Install R"
echo "###############"
sleep 3
sed -i '/deb-src http:\/\/us-east-1.ec2.archive.ubuntu.com\/ubuntu\/ trusty main/a deb http:\/\/cran.utstat.utoronto.ca\/bin\/linux\/ubuntu trusty\/' /etc/apt/sources.list
cat << EOF >> r-public-key.asc
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQENBEy9tcUBCACnWQfqdrcz7tQL/iCeWDYSYPwXpPMUMLE721HfFH7d8ErunPKP
Iwq1v4CrNmMjcainofbu/BfuZESSK1hBAItOk/5VTkzCJlzkrHY9g5v+XlBMPDQC
9u4AE/myw3p52+0NXsnBz+a35mxJKMl+9v9ztvueA6EmLr2xaLf/nx4XwXUMSi1L
p8i8XpAOz/Xg1fspPMRhuDAGYDnOh4uH1jADGoqYaPMty0yVEmzx74qvdIOvfgj1
6A/9LYXk67td6/JQ5LFCZmFsbahAsqi9inNgBZmnfXO4m4lhzeqNjJAgaw7Fz2zq
UmvpEheKKClgTQMWWNI9Rx1L8IKnJkuKnpzHABEBAAG0I01pY2hhZWwgUnV0dGVy
IDxtYXJ1dHRlckBnbWFpbC5jb20+iQE+BBMBAgAoBQJMvbXFAhsjBQkJZgGABgsJ
CAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBRcWYZ4ITauTy9B/4hmPQ7CSqw5OS5
t8U5y38BlqHflqFev3llX68sDtzYfxQuQVS3fxOBoGmFQ/LSfXQYhDG6BZa4nDuD
ZEgb81Mvj0DJDl4lmyMdBoIvXhvdEPDd/rrOG+1t2+S429W9NIObKaZCs9abv2fn
IhrtyAWxc/iNR5rJmNXozvJVGAgAeNhBSrvZqFaPJ//BklbJhfVgNwt4GgtFl1va
U7LMaMrOWA9Hyd8dWAGuIhbYXOOFj1WZ/OhUlYXnsIe8XzaJ1y6LyVkCLhaJ+MVt
GwTXrFXRhBLQlhCYBfO25i/PGUWSvRhI8n/r+RMNOuy1HlFbexRYrtPXOLbiO8Al
FuIsX9nRuQENBEy9tcUBCADYcCgQCCF1WUSn7c/VXNvgmXzvv3lVX9WkV4QdpcJX
itXglXdTZwVxGv3AxDuaLEwxW7rbqKRPzWNjj4xTHxt2YtUjE+mLV58AFaQQU3al
dYG8JPr2eohMNZqp2BG2odczw5eaO5l5ETjC1nHUjDUm8us3TV3AXOajAjguGvpG
3DKnx/gmudrMBVSAEE64kefyBmSR683zkXhw+NgbTID9XW1OSqE+fLQf0ZzQEojM
dfYIeV8Q5sMAmU3J9AdlpyDrZaYRmiphgw8PZTMahhz/o6Bz7p6VqA4Ncmr225nn
tIsjUUz0iK6TsaOi9KrF23Rw+IDUJeYkdVbwGqavgJG1ABEBAAGJASUEGAECAA8F
Aky9tcUCGwwFCQlmAYAACgkQUXFmGeCE2rlB9Qf+JKMUzM0KVdTFWocGP+v4xTJs
nKjYfjPjOkFYAdxhjkiIq7h7ws0s+UKqmzSG4vX5Qz46GZcB7x0hVrN0gqCcfpru
PZOjXNkRwtsXbLfiurrZQ6dSPsNIE9L4DZdSTggwC3i7jiDlK6TtIMXD55VoVvVA
vmzt6/f7y4qsVxhZ/N3jMqq1vLUESw8eVq2ryZRU9OIUufb5JjGNJ1Zz0Zp8hV/I
PLoIv1OIocWov27YLcr6EnXuvXvU/MSm97YifdG9UYCE99nHTioSM0Q3cgpu5Epp
VNrc232gyG2vlHzhsstNBx55cUmAX2fEzxuRipLS0iq4L0zUGdgdjn4noGDzGA==
=BF1w
-----END PGP PUBLIC KEY BLOCK-----
EOF
apt-key add r-public-key.asc

apt-get update
apt-get install -y r-base
apt-get install -y r-base-dev
apt-get install -y r-recommended

apt-get install -y libxml2-dev
# for libcurl-dev
apt-get install -y libcurl4-gnutls-dev

cat << EOF >> r-pkg
install.packages("RCurl", repos="http://cran.utstat.utoronto.ca/")
install.packages("XML", repos="http://cran.utstat.utoronto.ca/")
install.packages("BatchJobs", repos="http://cran.utstat.utoronto.ca/")
install.packages("Rmpi", repos="http://cran.utstat.utoronto.ca/", 
                 configure.args =
                 c("--with-Rmpi-include=/usr/local/openmpi/include/",
                   "--with-Rmpi-libpath=/usr/local/openmpi/lib/",
                   "--with-Rmpi-type=OPENMPI"))
install.packages("snow", repos="http://cran.utstat.utoronto.ca/")
source("http://bioconductor.org/biocLite.R")
biocLite("BiocParallel")
biocLite("GEOquery")
EOF

LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH Rscript r-pkg

###############
# Install R Studio
###############
echo "###############"
echo "Install R Studio"
echo "###############"
sleep 3
apt-get install -y gdebi-core
apt-get install -y libapparmor1 # Required only for Ubuntu, not Debian
wget http://download2.rstudio.org/rstudio-server-0.98.1103-amd64.deb
gdebi --n rstudio-server-0.98.1103-amd64.deb
# enable Rstudio health check 
#cp -f rserver.conf /etc/rstudio/rserver.conf

# set OL path for R Studio
cp -f Rprofile.site /etc/R/Rprofile.site

###############
# Install openlava
###############
echo "###############"
echo "Install openlava"
echo "###############"
sleep 3
apt-get install -y autoconf tcl tcl-dev automake bison flex libtool intltool xorg-dev libsamplerate-dev libncurses5-dev 
tar zxvf openlava-3.0.1.tar.gz
cd openlava-3.0.1
autoreconf --install
./configure --prefix=/opt/openlava-3.0.1
make
make install
ln -s /opt/openlava-3.0.1 /opt/openlava
cd config
cp lsf.conf lsb.hosts lsb.params lsb.queues lsb.users lsf.cluster.openlava lsf.shared lsf.task openlava.csh openlava.setup openlava.sh /opt/openlava/etc/

# comment out user groups that don't exist
mv -f /opt/teraproc/lsb.users /opt/openlava/etc
mv -f /opt/teraproc/lsb.queues /opt/openlava/etc
mv -f /opt/teraproc/lsb.params /opt/openlava/etc
mv -f /opt/teraproc/lsb.hosts /opt/openlava/etc
mv -f /opt/teraproc/lsf.cluster.openlava /opt/openlava/etc
sed -i "s/--skip-alias //" /opt/openlava/bin/openmpi-mpirun
cd $PWD

###############
# Install NFS pkg
###############
echo "###############"
echo "Install NFS "
echo "###############"
sleep 3
apt-get install -y nfs-common nfs-kernel-server

# exit the script before installing LDAP. Do LDAP
# installation by copying the cmds below to CLI
# You'll be asked to set LDAP admin password and 
# input it for initialization

###############
# Install LDAP
###############
echo "###############"
echo "Install LDAP "
echo "###############"
sleep 3
#apt-get install -y slapd ldap-utils
DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils libnss-ldap libpam-ldap ldap-auth-client nscd
# set admin pwd to be "admin123"
# #slappasswd -s admin123  ==> {SSHA}qAmpzQAYiyph3uyETQ79Ii21Uz36w7vI

cat >> pwd.ldif << EOF
dn: olcDatabase={1}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: {SSHA}qAmpzQAYiyph3uyETQ79Ii21Uz36w7vI
EOF
ldapmodify -Y EXTERNAL -H ldapi:/// -f pwd.ldif

# add LDAP base entries
cat >> ldap_base.ldif << EOF
dn: ou=people, dc=ec2,dc=internal
objectClass: organizationalUnit
ou: people

dn: ou=groups, dc=ec2,dc=internal
objectClass: organizationalUnit
ou: groups

EOF

#ldapadd -x -D "cn=admin,dc=ec2,dc=internal" -W -f ldap_base.ldif
aptitude update
aptitude install -y expect

VAR=$(expect -c '
spawn ldapadd -x -D "cn=admin,dc=ec2,dc=internal" -W -f ldap_base.ldif
expect "Enter LDAP Password:"
send "admin123\r"
expect eof
')

echo "$VAR"
service slapd restart

apt-get install -y ldapscripts
mv -f /opt/teraproc/ldapscripts.conf /etc/ldapscripts/
sh -c "echo -n 'admin123' > /etc/ldapscripts/ldapscripts.passwd"
chmod 400 /etc/ldapscripts/ldapscripts.passwd
mv -f /opt/teraproc/ldapadduser.template /etc/ldapscripts
mv -f /opt/teraproc/ldapaddgroup.template /etc/ldapscripts

#####
# get jq to parse JSON string for adding users
wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x ./jq
cp jq /usr/bin

####
# stop firewall
service ufw stop
ufw disable

echo "###############"
echo "Installation and Configuration finished. "
echo "###############"
