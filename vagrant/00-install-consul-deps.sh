#!/bin/bash

# Installing consul dependencies: git, ImageMagick, Ghostscript, Ruby >= 2.2.3, PostgreSQL >= 9.4, Phantomjs >= 2.0 (only for development)
yum install -y git ImageMagick ghostscript

# Ruby dependencies
yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel \
libyaml-devel libffi-devel openssl-devel make \
bzip2 autoconf automake libtool bison iconv-devel sqlite-devel

# Install RVM
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
usermod -a -G rvm vagrant

# Install ruby 2.2.3
rvm reload
rvm install 2.2.3
rvm use 2.2.3 --default
source /etc/profile.d/rvm.sh

gem install bundler

# Postgresql 9.4
curl -sSL -O http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm
yum localinstall -y pgdg-centos94-9.4-2.noarch.rpm
rm -fr pgdg-centos94-9.4-2.noarch.rpm
yum install -y postgresql94-server
cat << EOF > /etc/profile.d/pg.sh
PATH="${PATH}:/usr/pgsql-9.4/bin/"
EOF
source /etc/profile.d/pg.sh

# PostgreSQL initialization and start on boot
postgresql94-setup initdb
systemctl enable postgresql-9.4
systemctl start postgresql-9.4

# Required for gem pg
yum install -y postgresql94-devel

# Required for gem uglifier
curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
yum install -y nodejs gcc-c++ make

# Install PhantomJS 2.1.1
curl -sSL -O https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
tar -xjvf phantomjs-2.1.1-linux-x86_64.tar.bz2
cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin
rm -fr phantomjs-2.1.1-linux-x86_64
rm -f phantomjs-2.1.1-linux-x86_64.tar.bz2
