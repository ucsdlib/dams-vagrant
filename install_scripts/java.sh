###
# Java
###

# Java
apt-get install -y python-software-properties
add-apt-repository ppa:webupd8team/java
apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections
apt-get install -y oracle-java8-installer
yes "" | apt-get -f install
ln -s /usr/lib/jvm/java-8-oracle /usr/lib/jvm/default-java

# Maven
apt-get -y install maven

