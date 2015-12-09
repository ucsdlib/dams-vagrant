#!/bin/sh
echo "Cloning DAMSPAS..."
cd $1
git clone https://github.com/ucsdlib/damspas.git
cd damspas
git checkout -f develop

echo "Installing DAMSPAS..."
# copy config files
cp config/database.yml.sample config/database.yml
cp config/fedora.yml.sample config/fedora.yml
cp config/solr.yml.sample config/solr.yml
cp config/initializers/devise.rb.sample config/initializers/devise.rb
cp config/initializers/secret_token.rb.sample config/initializers/secret_token.rb

# install gems
bundle install

echo "Executing DAMSPAS test suite..."
# setup test DB and  run test suite
bundle exec rake db:migrate RAILS_ENV=test
bundle exec rake spec

# setup local db and start server
bundle exec rake db:migrate
echo "Starting DAMSPAS web server as background process..."
unicorn -D -p 3000
