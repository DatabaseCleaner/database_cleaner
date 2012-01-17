#!/bin/bash
set -x
set -e


# add the 10gen repo
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
sudo echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" >> /etc/apt/sources.list

sudo apt-get update
sudo apt-get install --yes couchdb mysql-server mongodb-10gen curl

# setup rvm
if [ ! -d "$HOME/.rvm"]
  bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
  echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile
  source ~/.bash_profile
  rvm install ruby-1.8.7-p248
fi
