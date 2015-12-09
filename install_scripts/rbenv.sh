#!/usr/bin/env bash

echo "Installing rbenv..."

# install rbenv and ruby-build
git clone git://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.profile
echo 'eval "$(rbenv init -)"' >> /home/vagrant/.profile
git clone git://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build
