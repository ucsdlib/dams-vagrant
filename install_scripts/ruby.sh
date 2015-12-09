#!/usr/bin/env bash

# install required ruby versions
echo "Installing ruby..."
ruby_version="$(curl -sSL https://raw.githubusercontent.com/ucsdlib/damspas/develop/.ruby-version)"
rbenv install "$ruby_version"
rbenv global "$ruby_version"
ruby -v
gem install bundler --no-ri --no-rdoc
rbenv rehash
