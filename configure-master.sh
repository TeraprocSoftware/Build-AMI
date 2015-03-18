#!/bin/sh

if [ $# != 2 ]; then
        echo "Usage: $0 cluster_admin_username cluster_admin_password"
        exit 1
fi

LOG_FILE="/opt/teraproc/configure-master.log"
show_message () {
        echo $1
        echo $1 >> $LOG_FILE 2>&1
}

show_message "Configure master node ..."

cluster_admin_username=$1
cluster_admin_password=$2
master_hostname=`hostname`

# mount device to be  /data
show_message "Mount device to /data ..."
device_name=`fdisk -l 2>&1 | grep "doesn't contain a valid partition table" | awk '{print $2}'`
if [ $device_name ]; then
        echo -e "o\nn\np\n1\n\n\nw" | fdisk $device_name >> $LOG_FILE 2>&1 
        partition_name=$device_name"1"
        mkfs -t ext4 $partition_name >> $LOG_FILE 2>&1
        mkdir /data >> $LOG_FILE 2>&1
	chmod 777 /data >> $LOG_FILE 2>&1
        mount $partition_name /data >> $LOG_FILE 2>&1
        echo "$partition_name       /data   ext4    defaults,discard        0 0" >> /etc/fstab
fi

# create LDAP group and add user
show_message "Add cluster admin user to LDAP server ..."
sed -i "s/LDAP_SERVER/$master_hostname/" /etc/ldapscripts/ldapscripts.conf >> $LOG_FILE 2>&1
/usr/sbin/ldapaddgroup cluster_users >> $LOG_FILE 2>&1
/usr/sbin/ldapadduser $cluster_admin_username cluster_users >> $LOG_FILE 2>&1
/usr/sbin/ldapaddusertogroup $cluster_admin_username cluster_users >> $LOG_FILE 2>&1
/usr/sbin/ldapsetpasswd $cluster_admin_username $cluster_admin_password >> $LOG_FILE 2>&1

# configure LDAP client
show_message "Configure LDAP client ..."
cp -f /opt/teraproc/ldap.conf /etc/ >> $LOG_FILE 2>&1
sed -i "s/LDAP_SERVER/$master_hostname/" /etc/ldap.conf >> $LOG_FILE 2>&1
cp -f /opt/teraproc/nsswitch.conf /etc/ >> $LOG_FILE 2>&1
/etc/init.d/nscd restart >> $LOG_FILE 2>&1
sleep 3
update-rc.d nscd enable >> $LOG_FILE 2>&1

# set Rstudio auth via pam ldap
show_message "Set Rstudio auth via pam ldap..."
cp -f /etc/pam.d/login /etc/pam.d/rstudio >> $LOG_FILE 2>&1
/usr/sbin/rstudio-server restart >> $LOG_FILE 2>&1

# Prepare home and ssh passwdless for cluster admin user 
show_message "Prepare home and ssh passwdless for cluster admin user ..."
mkdir /home/$cluster_admin_username >> $LOG_FILE 2>&1
mkdir /home/$cluster_admin_username/examples >> $LOG_FILE 2>&1
cp -f /opt/teraproc/basic-batch.R /home/$cluster_admin_username/examples >> $LOG_FILE 2>&1
cp -f /opt/teraproc/basic-rmpi.R /home/$cluster_admin_username/examples >> $LOG_FILE 2>&1
cp -f /opt/teraproc/batch.tmpl /home/$cluster_admin_username >> $LOG_FILE 2>&1
cp -f /opt/teraproc/interactive.tmpl /home/$cluster_admin_username >> $LOG_FILE 2>&1
chown -Rf $cluster_admin_username:cluster_users /home/$cluster_admin_username >> $LOG_FILE 2>&1
su - $cluster_admin_username -c "ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N '' -C $cluster_admin_username" >> $LOG_FILE 2>&1
su - $cluster_admin_username -c "cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys2 && chmod 0600 ~/.ssh/authorized_keys2" >> $LOG_FILE 2>&1
su - $cluster_admin_username -c "ssh-keyscan $master_hostname >> ~/.ssh/known_hosts && chmod 0600 ~/.ssh/known_hosts" >> $LOG_FILE 2>&1

# configure as openalva master
show_message "Configure as openalva master ..."
sed -i "s/Administrators = openlava/Administrators = $cluster_admin_username/" /opt/openlava/etc/lsf.cluster.openlava >> $LOG_FILE 2>&1
sed -i "s/MASTER_HOSTNAME/$master_hostname/" /opt/openlava/etc/lsf.cluster.openlava >> $LOG_FILE 2>&1
sed -i "s/MASTER_HOSTNAME/$master_hostname/" /opt/openlava/etc/lsb.hosts >> $LOG_FILE 2>&1
echo "LSB_SHORT_HOSTLIST=1" >> /opt/openlava/etc/lsf.conf
echo "LSF_LIM_IGNORE_CHECKSUM=y" >> /opt/openlava/etc/lsf.conf
chown -Rf $cluster_admin_username:cluster_users /opt/openlava >> $LOG_FILE 2>&1
chown -Rf $cluster_admin_username:cluster_users /opt/openlava-* >> $LOG_FILE 2>&1
cp /opt/openlava/etc/openlava.sh /etc/profile.d/ >> $LOG_FILE 2>&1
cp /opt/openlava/etc/openlava /etc/init.d/ >> $LOG_FILE 2>&1
/etc/init.d/openlava start >> $LOG_FILE 2>&1
update-rc.d openlava defaults >> $LOG_FILE 2>&1

# configure /home, /data to be shared
show_message "Export /home, /data ..."
cat >> /opt/teraproc/exports << EOF
/home *(rw,no_root_squash)
/data *(rw,no_root_squash)
EOF
cp -f /opt/teraproc/exports /etc/exports >> $LOG_FILE 2>&1
/etc/init.d/nfs-kernel-server restart >> $LOG_FILE 2>&1
update-rc.d nfs-kernel-server enable >> $LOG_FILE 2>&1

show_message "Configure master node ... complete. Check configure-master.log for details."

