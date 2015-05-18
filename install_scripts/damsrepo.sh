#!/bin/sh

SHARED_DIR=$1

# build webapp
git clone https://github.com/ucsdlib/damsrepo.git
cd damsrepo
ant webapp

# setup dams config
export DAMS_HOME=/pub/dams
sudo mkdir -p $DAMS_HOME
sudo mkdir -p $DAMS_HOME/editBackups
sudo mkdir -p $DAMS_HOME/xsl
sudo cp src/lib2/postgresql-9.2-1002.jdbc4.jar /usr/share/tomcat7/lib/
sudo cp src/properties/jhove.conf $DAMS_HOME/
sudo cp $SHARED_DIR/config/dams.properties $DAMS_HOME/
sudo cp $SHARED_DIR/config/99dams.policy /etc/tomcat7/policy.d/
sudo cp $SHARED_DIR/config/xsl/* $DAMS_HOME/xsl/
sudo chown -R tomcat7:tomcat7 $DAMS_HOME

# setup db
sudo /etc/init.d/postgresql start
sudo -u postgres psql -c "create user dams with password 'dams';"
sudo -u postgres psql -c "create database dams owner dams;"
tmp/commands/ts-init.sh dams
tmp/commands/ts-load-raw.sh dams tmp/sample/predicates/
tmp/commands/ts-init.sh events
tmp/commands/ts-load-raw.sh events tmp/sample/predicates/

# copy tomcat server.xml
sed -i '/<GlobalNamingResources>/a <Environment name="dams/home" value="/pub/dams" type="java.lang.String"/>
  /<GlobalNamingResources>/a    <Resource name="jdbc/dams" auth="Container" type="javax.sql.DataSource" username="dams" password="dams" driverClassName="org.postgresql.Driver" maxActive="10" maxIdle="3" url="jdbc:postgresql://localhost/dams" maxWait="5000" validationQuery="select 1" logAbandoned="true" testOnBorrow="true" removeAbandonedTimeout="60" removeAbandoned="true" testOnReturn="true"/>' /var/lib/tomcat7/conf/server.xml
sudo service tomcat7 restart

# deploy webapp
ant -Ddeploy.home=/var/lib/tomcat7/webapps local-deploy
