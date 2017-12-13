#!/bin/bash

## Application Security Threat Attack Modeling (ASTAM)
##
## Copyright (C) 2017 Applied Visions - http://securedecisions.com
##
## Written by Aspect Security - http://aspectsecurity.com
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

# Include the demo dictionary file
ln -s /opt/attack-scripts/crydra16/samples/sample-dictionary-02.txt /usr/local/bin

# map target.example.com to internal instance of dotCMS
echo "127.0.0.1 target.example.com" >> /etc/hosts

cd ~

## install dotCMS
echo "Downloading dotCMS (this make take a few minutes...)"
wget -q "https://dotcms.com/physical_downloads/release_builds/dotcms_3.3.1.tar.gz"
mkdir -p /opt/dotCMS

echo "Extracting dotCMS"
tar xzf dotcms_3.3.1.tar.gz -C /opt/dotCMS/

echo "Installing MySQL & Java"
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get update
apt-get install -y mysql-server mysql-client openjdk-8-jdk

echo "Setting up MySQL"
if ! grep "lower_case_table_names=1" /etc/mysql/my.cnf ; then
  sed -i '/\[mysqld\]/alower_case_table_names=1' /etc/mysql/my.cnf
  service mysql restart
fi

echo "Configuring dotCMS to use MySQL"
echo 'create database dotcms default character set = utf8 default collate = utf8_general_ci;' | mysql --password=root
# necessary updates in context.xml
cd /opt/dotCMS/dotserver/tomcat-8.?.*/webapps/ROOT/META-INF
cat context.xml | sed '29s/-->//' | sed '37s/^.*$/ -->/' | sed '47s/$/ -->/' | sed '54s/^.*$//' | sed '50s/dotcms2/dotcms/' | sed '51s/{your db user}/root/' | sed '51s/{your db password}/root/' > context.tmp
mv context.tmp context.xml

cat << EOF > /etc/systemd/system/dotcms.service

[Unit]
Description=dotCMS
After=network.target

[Service]
Type=simple
ExecStart=/opt/dotCMS/bin/startup.sh run

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable dotcms
systemctl start dotcms

echo "Initializing dotCMS (this may take several minutes)..."
wget -q localhost:8080 -O /dev/null

echo "Setup complete"
