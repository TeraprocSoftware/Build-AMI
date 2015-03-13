#!/bin/sh

if [ $# != 2 ]; then
        echo "Usage: $0 master_hostname cluster_admin_username"
        exit 1
fi

LOG_FILE="/opt/teraproc/configure-slave.log"
show_message () {
        echo $1
        echo $1 >> $LOG_FILE 2>&1
}

show_message "Configure slave node ..."

master_hostname=$1
cluster_admin_username=$2
local_hostname=`hostname`

# configure LDAP client
show_message "Configure LDAP client"
service slapd stop >> $LOG_FILE 2>&1
update-rc.d slapd disable >> $LOG_FILE 2>&1
cp -f /opt/teraproc/ldap.conf /etc/ >> $LOG_FILE 2>&1
sed -i "s/LDAP_SERVER/$master_hostname/" /etc/ldap.conf >> $LOG_FILE 2>&1
cp -f /opt/teraproc/nsswitch.conf /etc/ >> $LOG_FILE 2>&1
/etc/init.d/nscd restart >> $LOG_FILE 2>&1
update-rc.d nscd enable >> $LOG_FILE 2>&1

# check if master is ready to proceed otherwise wait.
show_message "Mount master /home to slave ..."
loop=0
while true; do
	rpcinfo $master_hostname | grep mountd >> /dev/null
        if [ ! $? -eq 0 ]; then
                show_message "Warning: NFS service on master host is not ready. Retry ..."
                sleep 15
        else
                break
        fi
        loop=`expr $loop + 1`
        if [ $loop -gt 39 ]; then
                show_message "Error: NFS service on master host is not ready. configure slave exits."
                exit 1
        fi
done

# mount /home from openlava master
#initctl restart idmapd
mount -t nfs $master_hostname:/home /home >> $LOG_FILE 2>&1
sed -i "s/master_hostname/$master_hostname/" /opt/teraproc/fstab >> $LOG_FILE 2>&1
mv -f /opt/teraproc/fstab /etc/fstab >> $LOG_FILE 2>&1
show_message "Mount master /home to slave ... done"

# stop nfs server
/etc/init.d/nfs-kernel-server stop >> $LOG_FILE 2>&1
update-rc.d nfs-kernel-server enable >> $LOG_FILE 2>&1

# remove rstudio server
apt-get remove -y rstudio-server >> $LOG_FILE 2>&1

# For every existing user, add slave node to the known hosts file.
show_message "Configure SSH access for all existing users..."
sed -i "s/LDAP_SERVER/$master_hostname/" /etc/ldapscripts/ldapscripts.conf >> $LOG_FILE 2>&1
USERS=`lsldap -u | grep "dn:" |sed "s/dn: uid=//" | cut -d, -f1` >> $LOG_FILE 2>&1
for user in $USERS; do
        su - $user -c "ssh-keyscan ${local_hostname} >> ~/.ssh/known_hosts && chmod 0600 ~/.ssh/known_hosts" >> $LOG_FILE 2>&1
done
show_message "Configure SSH access for all existing users... done"

# configure as openalva slave
show_message "Configure openlava slave node ..."
sed -i "s/Administrators = openlava/Administrators = $cluster_admin_username/" /opt/openlava/etc/lsf.cluster.openlava >> $LOG_FILE 2>&1
sed -i "s/MASTER_HOSTNAME/$master_hostname/" /opt/openlava/etc/lsf.cluster.openlava >> $LOG_FILE 2>&1
sed -i "s/MASTER_HOSTNAME/$master_hostname/" /opt/openlava/etc/lsb.hosts >> $LOG_FILE 2>&1
sed -i "/$master_hostname/a $local_hostname   IntelI5      linux   1      3.5    (cs)" /opt/openlava/etc/lsf.cluster.openlava >> $LOG_FILE 2>&1
cp /opt/openlava/etc/openlava.sh /etc/profile.d/ >> $LOG_FILE 2>&1
cp /opt/openlava/etc/openlava /etc/init.d/ >> $LOG_FILE 2>&1
. /etc/profile.d/openlava.sh >> $LOG_FILE 2>&1
echo "LIM_COMPUTE_ONLY=y" >> $LSF_ENVDIR/lsf.conf
echo "LSF_ROOT_REX=y" >> $LSF_ENVDIR/lsf.conf
echo "LSF_LIM_IGNORE_CHECKSUM=y" >> $LSF_ENVDIR/lsf.conf
echo "LSF_SERVER_HOSTS=$master_hostname" >> $LSF_ENVDIR/lsf.conf
chown -Rf $cluster_admin_username:cluster_users /opt/openlava >> $LOG_FILE 2>&1
chown -Rf $cluster_admin_username:cluster_users /opt/openlava-* >> $LOG_FILE 2>&1
/etc/init.d/openlava start >> $LOG_FILE 2>&1
loop=0
while true; do
	su - $cluster_admin_username -c "$LSF_ENVDIR/../bin/lsaddhost $local_hostname" >> $LOG_FILE 2>&1
        if [ ! $? -eq 0 ]; then
                show_message "Warning: Openlava on master host is not ready to add this slave. Retry ..."
                sleep 15
        else
                break
        fi
        loop=`expr $loop + 1`
        if [ $loop -gt 39 ]; then
                show_message "Error: Openlava on master host is not ready to add this slave. Exit ..."
                exit 1
        fi
done
update-rc.d openlava defaults >> $LOG_FILE 2>&1
show_message "Configure openlava slave node ... done"

show_message "Configure slave node ... complete. Check configure-slave.log for details."

