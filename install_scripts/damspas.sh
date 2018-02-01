#!/bin/sh
echo "Cloning DAMSPAS..."
cd $1
git clone https://github.com/ucsdlib/damspas.git
cd damspas
git checkout -f develop

echo "Installing DAMSPAS..."

# install gems
bundle install

echo "Executing DAMSPAS test suite..."
# setup test DB and  run test suite
bundle exec rake db:migrate RAILS_ENV=test
bundle exec rake spec

# setup local db and start server
bundle exec rake db:migrate
echo "Starting DAMSPAS web server as background process..."
bundle exec unicorn -D -p 3000
