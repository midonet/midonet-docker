#!/bin/sh

# Update the  config file with environment variables
# The pattern is /^[ ]*property/ s/=.*/= $VARIABLE/
#  ^[# ]*         matches the start of line with trailing blanks or comments
#  /property[ ]*= matches a line with the property name and a value assigment
#  s/^.*/         matches any current value of the line
#  /property = $VARIABLE   does the substitution of the valie

cat > /etc/keystone/keystone.conf << EOF
[DEFAULT]
admin_token = $OS_TOKEN
verbose = $OS_VERBOSE
debug = $OS_DEBUG
log_dir = /var/log/keystone

[database]
connection = mysql://$DB_USER:$DB_PASSWORD@$DB_HOST/$DB_NAME
EOF


while ! nc -z $DB_HOST 3306; do
    /bin/sleep 3;
    echo "MariaDB not running yet at host ${DB_HOST}"
done

keystone-manage --log-file=/var/log/keystone.log db_sync

python /usr/bin/keystone-all --config-file=/etc/keystone/keystone.conf --log-file=/var/log/keystone.log
