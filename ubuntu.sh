#!/bin/bash

for i in "$@"; do
    case $i in
        --ruby_version=*)
            RUBY_VERSION_TO_INSTALL="${i#*=}"
            RUBY_PACKAGE="ruby-$RUBY_VERSION_TO_INSTALL.tar.gz"
            shift
            ;;
        --h)
            echo "This script is used to install the ruby from source."
            echo "Valid options are:"
            echo "  --ruby_version=x.x.x"
            echo "  --h for this screen."
            exit 1
            ;;
        *)
            echo "$i is not vaild"
            exit 1
        ;;
    esac;
done

[[ -z $RUBY_VERSION_TO_INSTALL ]] && echo -ne "\nRUBY_VERSION not set.\n\n" && exit 1

[[ -e "/usr/local/bin/ruby" ]] && echo "You already have Ruby installed.." && exit 1

if [ -f "/etc/lsb-release" ]; then
    source /etc/lsb-release
    [[ "$DISTRIB_CODENAME" != "xenial" ]] && echo "This script works only on Ubuntu 16.04." && exit 1
else
    echo "This script works only on Ubuntu 16.04."
    exit 1
fi

SCRIPT_DIR="/usr/local/src"
DEPENDECIES_PACKAGES="apt-utils wget gzip autoconf build-essential libreadline6-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libssl-dev libyaml-dev zlib1g-dev nodejs libcurl4-openssl-dev libxslt1-dev python-software-properties libxml2-dev sqlite3 libsqlite3-dev curl"

clear

echo " "
echo "Starting the script ..."

[[ -e $SCRIPT_DIR/$RUBY_PACKAGE ]] && rm -rf $SCRIPT_DIR/$RUBY_PACKAGE
cd $SCRIPT_DIR

echo "Updating ..."
apt-get update -q > /dev/null 2>&1

echo "Installing dependencies ..."
apt-get install -q -y $DEPENDECIES_PACKAGES > /dev/null 2>&1

echo "Downloading the ruby-$RUBY_VERSION_TO_INSTALL ..."
wget http://cache.ruby-lang.org/pub/ruby/$RUBY_PACKAGE -O $SCRIPT_DIR/$RUBY_PACKAGE > /dev/null 2>&1

echo "Unpacking the ruby package ..."
tar xvfz $RUBY_PACKAGE > /dev/null 2>&1
cd ruby-$RUBY_VERSION_TO_INSTALL

echo "Compiling the ruby-$RUBY_VERSION_TO_INSTALL ..."
./configure --disable-install-doc > /dev/null 2>&1
make --jobs $(nproc) > /dev/null 2>&1
make install > /dev/null 2>&1

echo "Installing the bundler ..."
gem install bundler > /dev/null 2>&1

echo "Cleaning up..."
rm -rf $SCRIPT_DIR/ruby-$RUBY_VERSION_TO_INSTALL > /dev/null 2>&1
rm -f $SCRIPT_DIR/$RUBY_PACKAGE > /dev/null 2>&1

export RUBY_VERSION=$RUBY_VERSION_TO_INSTALL
export RUBY_MAJOR=$(echo $RUBY_VERSION | cut -d "." -f 1,2)

echo -ne "\nScript successfully completed!\n"
echo "========================================="
echo -ne "\nRuby version: `ruby -v`"
echo -ne "\nBundle version: `bundle -v`"
echo -ne "\nGem version: `gem -v`"
echo -ne "\nIrb version: `irb -v`\n"
echo " "
