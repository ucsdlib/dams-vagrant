###
# TOMCAT 7
###

# Tomcat
apt-get -y install tomcat7 tomcat7-admin
usermod -a -G tomcat7 vagrant

if ! grep -q "role rolename=\"fedoraAdmin\"" /etc/tomcat7/tomcat-users.xml ; then
  sed -i '$i<role rolename="fedoraUser"/>
  $i<role rolename="fedoraAdmin"/>
  $i<role rolename="dams-curator"/>
  $i<role rolename="dams-rci"/>
  $i<role rolename="dams-manager-admin"/>
  $i<role rolename="manager-gui"/>
  $i<user username="dams" password="dams" roles="dams-curator,dams-rci,dams-manager-admin"/>
  $i<user username="testuser" password="password1" roles="fedoraUser"/>
  $i<user username="adminuser" password="password2" roles="fedoraUser"/>
  $i<user username="fedoraAdmin" password="secret3" roles="fedoraAdmin"/>
  $i<user username="fedora4" password="fedora4" roles="manager-gui"/>' /etc/tomcat7/tomcat-users.xml
fi
