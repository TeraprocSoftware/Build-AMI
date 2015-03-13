#!/bin/sh

# This script reads user JSON string from environment varialbe REMOVE_USERS
# The formate is like below
#REMOVE_USERS="{\"users\":[{\"username\":\"user201\"},{\"username\":\"user202\"}]}"

LOG_FILE="remove-user.log"
show_message () {
        echo $1
        echo $1 >> $LOG_FILE 2>&1
}

show_message "Removing users ..."

. /etc/profile.d/openlava.sh

usergroup="cluster_users"

num=0
while true; do
        username=`echo $REMOVE_USERS | jq ".users[$num].username"`

        if [ $username = null ]; then
                show_message "Complete removing users!"
                /etc/init.d/nscd restart >> $LOG_FILE 2>&1
                break
        fi
        username=`echo $username | sed "s/\"//g"`
        show_message "Removing user: $username"

        /usr/sbin/ldapdeleteuserfromgroup $username $usergroup >> $LOG_FILE 2>&1
        /usr/sbin/ldapdeleteuser $username >> $LOG_FILE 2>&1

        rm -rf /home/$username >> $LOG_FILE 2>&1

        # kill user's r session as logging out rstudio doesn't do this so far.
        session_process=`ps -ef | grep "/usr/lib/rstudio-server/bin/rsession -u $username" | grep -v -e "grep" | awk '{print $2}'`
        kill -9 $session_process >> $LOG_FILE 2>&1

        num=`expr $num + 1`
done

