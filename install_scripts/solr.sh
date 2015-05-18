
echo "Installing Solr"

SHARED_DIR=$1

if [ -f "$SHARED_DIR/install_scripts/config" ]; then
  . $SHARED_DIR/install_scripts/config
fi

if [ ! -d $SOLR_HOME ]; then
  mkdir $SOLR_HOME
fi

cp -a $SHARED_DIR/config/solr/* $SOLR_HOME/
chown -R tomcat7:tomcat7 $SOLR_HOME

cp $SHARED_DIR/config/solr.war /var/lib/tomcat7/webapps/
chown tomcat7:tomcat7 /var/lib/tomcat7/webapps/solr.war
