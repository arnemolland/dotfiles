#!/bin/bash

cd /tmp

wget "https://github.com/IBM/type/archive/master.zip"

unzip master.zip
rm master.zip

cd type-master

sudo mkdir -p /usr/share/fonts/truetype/ibm-plex
sudo mkdir -p /usr/share/fonts/opentype/ibm-plex

sudo cp /tmp/type-master/fonts/*/desktop/pc/*.ttf /usr/share/fonts/truetype/ibm-plex/.
sudo cp /tmp/type-master/fonts/*/desktop/mac/*.otf /usr/share/fonts/opentype/ibm-plex/.

sudo fc-cache -fv
