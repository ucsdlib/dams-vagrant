#!/bin/sh
echo "Setting up Wowza key for DAMSPAS..."
# setup wowza streaming key
WOWZA_DIR=/pub/data2/dams
sudo mkdir -p ${WOWZA_DIR}
sudo touch ${WOWZA_DIR}/streaming.key
sudo echo "1234123123123123" > ${WOWZA_DIR}/streaming.key
sudo chown -R vagrant:vagrant $WOWZA_DIR
