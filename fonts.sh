#!/bin/bash
brew install fontconfig wget

cd /tmp

wget "https://github.com/IBM/type/archive/master.zip"

unzip master.zip
rm master.zip

cd plex-master

case `uname` in
  Darwin)
    yes | sudo cp /tmp/plex-master/*/fonts/complete/otf/*.otf /Library/Fonts/.
  ;;
  Linux)
    sudo mkdir -p /usr/share/fonts/truetype/ibm-plex
    sudo mkdir -p /usr/share/fonts/opentype/ibm-plex
    sudo cp /tmp/plex-master/*/fonts/complete/ttf/*.ttf /usr/share/fonts/truetype/ibm-plex/.
    sudo cp /tmp/plex-master*/fonts/complete/otf/*.otf /usr/share/fonts/opentype/ibm-plex/.
  ;;
esac

sudo fc-cache -fv
