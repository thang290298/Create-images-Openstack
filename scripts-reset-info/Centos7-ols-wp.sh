#!/bin/bash
# CentOS7-ols-WP
# ThangNV NhanHoa Cloud Team 

# Get info mysql_root_passwd and da_admin(mysql_admin_passwd) password
old_passwd_1=Nhanhoa20211
old_passwd_2=Nhanhoa20212
new_ip=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
# Input from cloud-init
new_passwd_1=$1
new_passwd_2=$2
new_passwd_3=$3
new_passwd_4=$4
# Input from random 
# new_passwd_1=$(date +%s | sha256sum | base64 | head -c 16 ; echo)
# new_passwd_2=$(date +%s | sha256sum | base64 | head -c 10 ; echo)
# new_passwd_3=$(date +%s | sha256sum | base64 | head -c 10 ; echo)
# new_passwd_4=$(date +%s | sha256sum | base64 | head -c 10 ; echo)

# Change password
mysqladmin --user=root --password=$old_passwd_1 password $new_passwd_1
mysqladmin --user=wp_user --password=$old_passwd_2 password $new_passwd_2
echo -e "admin\n$new_passwd_3\n$new_passwd_3" | /usr/local/lsws/admin/misc/admpass.sh

# Save to setting wp-config.php
sed -Ei "s|'$old_passwd_2'|'$new_passwd_2'|g" /usr/local/lsws/wordpress/wp-config.php

# Config mysql
mysql -u root -p$new_passwd_1 -e "SET GLOBAL max_connections = 500;
SET GLOBAL connect_timeout = 100;
SET GLOBAL sql_mode='NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
drop database sys;
drop database performance_schema;

FLUSH PRIVILEGES;"
echo "DONE"

# update info wordpress
cd /usr/local/lsws/wordpress
wp search-replace http://10.10.13.214 http://$new_ip --allow-root
wp cache flush --allow-root
wp user update 1 --user_pass=$new_passwd_4 --allow-root
wp cache flush --allow-root

# change password info file
sed -i "s|Nhanhoa20211|$new_passwd_1|g" /usr/local/lsws/password
sed -i "s|Nhanhoa20212|$new_passwd_2|g" /usr/local/lsws/password
sed -i "s|0435626533aA|$new_passwd_3|g" /usr/local/lsws/password
sed -i "s|Nhanhoa20213|$new_passwd_4|g" /usr/local/lsws/password
# DONE 
echo "DONE"