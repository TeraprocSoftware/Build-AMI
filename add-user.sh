#!/bin/sh

# This script reads user JSON string from environment varialbe ADD_USERS
# The formate is like below
#ADD_USERS="{\"users\":[{\"username\":\"user301\",\"password\":\"{SSHA}942hliXbDrnQDECq0sB4fZjKsZBcXeg7\"},{\"username\":\"user302\",\"password\":\"{SSHA}GqcVUuC0CFtCBAQ9wLTgojo2+SwDxyoq\"}]}"

LOG_FILE="add-user.log"
show_message () {
        echo $1
        echo $1 >> $LOG_FILE 2>&1
}

show_message "Adding users ..."

. /etc/profile.d/openlava.sh

usergroup="cluster_users"

num=0
while true; do
        username=`echo $ADD_USERS | jq ".users[$num].username"`
        password=`echo $ADD_USERS | jq ".users[$num].password"`

        if [ $username = null ]; then
                show_message "Complete adding users!"
                break
        fi
        username=`echo $username | sed "s/\"//g"`
        password=`echo $password | sed "s/\"//g"`
        show_message "Adding user: $username"

        /usr/sbin/ldapadduser $username $usergroup >> $LOG_FILE 2>&1
        /usr/sbin/ldapaddusertogroup $username $usergroup >> $LOG_FILE 2>&1
        /usr/sbin/ldapsetpasswd $username $password >> $LOG_FILE 2>&1
        /etc/init.d/nscd restart >> $LOG_FILE 2>&1
        sleep 1

        # Prepare home and ssh passwdless for cluster admin suer
        mkdir /home/$username >> $LOG_FILE 2>&1
        mkdir /home/$username/examples >> $LOG_FILE 2>&1
        cp -f /opt/teraproc/basic-batch.R /home/$username/examples >> $LOG_FILE 2>&1
        cp -f /opt/teraproc/batch.tmpl /home/$username >> $LOG_FILE 2>&1
        cp -f /opt/teraproc/interactive.tmpl /home/$username >> $LOG_FILE 2>&1
        chown -Rf $username:cluster_users /home/$username >> $LOG_FILE 2>&1
        su - $username -c "ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N '' -C $username" >> $LOG_FILE 2>&1
        su - $username -c "cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys2 && chmod 0600 ~/.ssh/authorized_keys2" >> $LOG_FILE 2>&1

        # Need to copy known_host file from another user .ssh dir
        # get cluster admin username and copy /home/<username>/.ssh/known_hosts and then change ownership of the file.
        cluster_admin=`cat $LSF_ENVDIR/lsf.cluster.openlava | grep "Administrators = " | sed "s/ //g" |cut -d= -f2` >> $LOG_FILE 2>&1
        cp -f /home/$cluster_admin/.ssh/known_hosts /home/$username/.ssh >> $LOG_FILE 2>&1
        chown $username:$usergroup /home/$username/.ssh/known_hosts >> $LOG_FILE 2>&1
        chmod 600 /home/$username/.ssh/known_hosts >> $LOG_FILE 2>&1

        num=`expr $num + 1`
done

