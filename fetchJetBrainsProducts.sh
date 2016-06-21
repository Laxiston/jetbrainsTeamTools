#!/bin/bash

type="y"
echo "Y - Run products extraction."
echo -n "Do you want to continue? [Y|n]: "
read type

if [ "$type" == "n" ]; then
  exit 0
fi

mkdir -p /usr/jetbrains/youtrack
mkdir -p /usr/jetbrains/hub
mkdir -p /usr/jetbrains/upsource
mkdir -p /usr/jetbrains/teamcity

wget http://download.jetbrains.com/hub/2.0/hub-ring-bundle-2.0.244.zip -O /usr/jetbrains/hub/arch.zip

wget http://download.jetbrains.com/charisma/youtrack-6.5.17105.zip -O /usr/jetbrains/youtrack/arch.zip

wget http://download.jetbrains.com/upsource/upsource-3.0.4364.zip -O /usr/jetbrains/upsource/arch.zip

wget http://download.jetbrains.com/teamcity/TeamCity-9.1.7.tar.gz -O /usr/jetbrains/teamcity/arch.tar.gz

cd /usr/jetbrains/hub
unzip arch.zip

cd /usr/jetbrains/youtrack
unzip arch.zip

cd /usr/jetbrains/upsource
unzip arch.zip
mv upsource-*/** ../upsource/
chmod +x -R ../upsource/

cd /usr/jetbrains/teamcity
tar -xzvf arch.tar.gz
mv TeamCity/** ../teamcity/
chmod +x -R ../teamcity/
cd ~

echo "All products are downloaded and extracted in /usr/jetbrains/ location."

