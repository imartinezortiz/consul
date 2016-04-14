#!/bin/bash

cd /vagrant

# pg create consul user
cat <<EOF | sudo -u postgres psql
CREATE USER consul WITH PASSWORD 'consul' CREATEDB;
ALTER USER consul WITH SUPERUSER;
EOF

cat <<EOF | sudo -u postgres psql
CREATE DATABASE consul_development OWNER consul TEMPLATE template0 ENCODING 'UTF-8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
CREATE DATABASE consul_test OWNER consul TEMPLATE template0 ENCODING 'UTF-8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
EOF
# pg enable md5 authentication method for user consul through localhost
yum install -y patch
sudo bash -c 'pushd /var/lib/pgsql/9.4/data
cat <<EOF | patch
--- pg_hba.conf	2016-01-26 17:45:04.988848551 +0100
+++ pg_hba.conf.consul	2016-01-26 17:47:33.766208810 +0100
@@ -78,6 +78,9 @@
 
 # "local" is for Unix domain socket connections only
 local   all             all                                     peer
+# Consul rules
+host	   all		         consul		       127.0.0.1/32		         md5
+host	   all		         consul		       ::1/128			           md5
 # IPv4 local connections:
 host    all             all             127.0.0.1/32            ident
 # IPv6 local connections:
EOF
popd'
sudo systemctl restart postgresql-9.4

# Required for bin/rake db:setup
sudo yum install -y postgresql94-contrib
cat <<EOF | sudo -u postgres psql consul_development
CREATE EXTENSION unaccent;
CREATE EXTENSION pg_trgm;
EOF
cat <<EOF | sudo -u postgres psql consul_test
CREATE EXTENSION unaccent;
CREATE EXTENSION pg_trgm;
EOF
