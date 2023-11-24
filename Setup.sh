#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Install dependencies
yum install glibc.i686 gcc gcc-c++ mysql-devel boost-devel.x86_64 libxml2-devel.x86_64 log4cxx-devel.x86_64 jansson-devel.x86_64 git -y

# Install MySQL 5.6
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install -y mysql-server

# Start and enable MySQL service
systemctl start mysqld.service
systemctl enable mysqld.service
systemctl status mysqld.service

# Set MySQL root password and grant privileges (Replace '123456' with the desired password)
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('romth1520');"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'romth1520' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Stop and disable firewalld (Caution: This will make the system less secure)
systemctl stop firewalld.service
systemctl disable firewalld.service

# Install protobuf
cd /root
unzip protobuf-2.6.1.zip
chmod -R 777 protobuf-2.6.1
cd protobuf-2.6.1
./configure --prefix=/usr/local/protobuf
make && make install

yum install protobuf-compiler -y
protoc --version

# Install jemalloc
cd /root
unzip jemalloc-3.4.0.zip
chmod -R 777 jemalloc-3.4.0
cd jemalloc-3.4.0
./configure 
make && make install

# Install hiredis
cd
wget https://github.com/redis/hiredis/archive/v0.13.3.tar.gz
tar -xzvf v0.13.3.tar.gz
cd hiredis-0.13.3
make && make install

# Install cmake
cd
wget https://cmake.org/files/v3.12/cmake-3.12.0-rc1.tar.gz
tar -zxvf cmake-3.12.0-rc1.tar.gz
cd cmake-3.12.0-rc1
./bootstrap
gmake
gmake install

cmake --version

# Install googletest
cd /root
unzip googletest-release-1.8.0.zip
chmod -R 777 googletest-release-1.8.0
cd googletest-release-1.8.0
cmake CMakeLists.txt
make

# Install Redis 4.0.6
cd
wget http://download.redis.io/releases/redis-4.0.6.tar.gz
tar -zxvf redis-4.0.6.tar.gz
cd redis-4.0.6
make MALLOC=libc
make install

# Configure Redis as a daemon
sed -i 's/^daemonize no/daemonize yes/' /root/redis-4.0.6/redis.conf

# Set up Redis to start on boot
cd /etc
mkdir redis
cp /root/redis-4.0.6/redis.conf /etc/redis/6379.conf
cp /root/redis-4.0.6/utils/redis_init_script /etc/init.d/redisd
# Add chkconfig info to redisd
sed -i '1i # chkconfig:   2345 90 10' /etc/init.d/redisd
sed -i '2i # description:  Redis is a persistent key-value database' /etc/init.d/redisd
chkconfig redisd on

# Start Redis service
service redisd start

# Install PHP 7.0 and extensions
rpm -ivh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php70
yum -y install php70 php70-php-fpm php70-php-pecl-swoole2.x86_64 php70-php-pecl-msgpack.x86_64 php70-php-pecl-redis.x86_64 php70-php-pecl-ds.x86_64 php70-php-pecl-yaml.x86_64 php70-php-pecl-lua.x86_64

# Symlink PHP to a global path
ln -s /opt/remi/php70/root/usr/bin/php /usr/bin/php

# Now that the symlink is created, check the PHP version and modules
php -v
php -m

# Start PHP 7.0 service
systemctl restart php70-php-fpm.service
systemctl enable php70-php-fpm.service

# Install Fluentd (td-agent)
curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh

# Start and enable td-agent service
systemctl start td-agent.service
systemctl enable td-agent.service

# Install Composer securely
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

# This is the end of the script
echo "Installation process is completed."