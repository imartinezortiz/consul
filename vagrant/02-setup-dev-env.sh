#!/bin/bash

# Disable firewall
sudo systemctl disable firewalld
sudo systemctl stop firewalld

source /etc/profile.d/rvm.sh
cd /vagrant
bundle install
sed -e 's/@pgusername@/consul/' -e 's/@pgpassword@/consul/' config/database.yml.example > config/database.yml
cp config/secrets.yml.example config/secrets.yml
rake db:setup
rake db:dev_seed
RAILS_ENV=test rake db:setup
