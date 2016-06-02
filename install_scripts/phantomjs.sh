#!/usr/bin/env bash

echo "Installing PhantomJS.."
PHANTOM_VERSION="phantomjs-2.1.1-linux-x86_64"
cd /usr/local/share
sudo wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_VERSION.tar.bz2
sudo tar xjf $PHANTOM_VERSION.tar.bz2
sudo ln -s /usr/local/share/$PHANTOM_VERSION/bin/phantomjs /usr/local/share/phantomjs
sudo ln -s /usr/local/share/$PHANTOM_VERSION/bin/phantomjs /usr/local/bin/phantomjs
## system wide
sudo ln -s /usr/local/share/$PHANTOM_VERSION/bin/phantomjs /usr/bin/phantomjs
