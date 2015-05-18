###
# BASICS
###

SHARED_DIR=$1

if [ -f "$SHARED_DIR/install_scripts/config" ]; then
  . $SHARED_DIR/install_scripts/config
fi

cd $HOME_DIR

# Update
apt-get -y update && apt-get -y upgrade

# SSH
apt-get -y install openssh-server

# Build tools
apt-get -y install build-essential

# Git vim
apt-get -y install git vim

# Wget and curl
apt-get -y install wget curl

# More helpful packages
apt-get -y install htop tree zsh fish

# Postgresql
apt-get -y install postgresql

# Image Magick
apt-get -y install imagemagick

# Ffmpeg
sudo add-apt-repository ppa:mc3man/trusty-media
sudo apt-get update
sudo apt-get install -y ffmpeg
