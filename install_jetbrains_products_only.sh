#!/bin/bash

apt-get install mc htop git unzip wget curl -y

echo
echo "====================================================="
echo "                     WELCOME"
echo "====================================================="
echo
echo "Hub"
echo "download https://www.jetbrains.com/hub/download/"
echo "read instruction https://www.jetbrains.com/hub/help/1.0/Installing-Hub-with-Zip-Distribution.html"
echo "install into /usr/jetbrains/hub/"
echo "====================================="
echo
echo "YouTrack"
echo "download https://www.jetbrains.com/youtrack/download/get_youtrack.html"
echo "read instruction https://confluence.jetbrains.com/display/YTD65/Installing+YouTrack+with+ZIP+Distribution#InstallingYouTrackwithZIPDistribution-InstallingNewYouTrackServer"
echo "install into /usr/jetbrains/youtrack/"
echo "====================================="
echo
echo "Upsource"
echo "download https://www.jetbrains.com/upsource/download/"
echo "read the first https://www.jetbrains.com/upsource/help/2.0/prerequisites.html"
echo "install into /usr/jetbrains/upsource/"
echo "====================================="
echo

type="y"
echo "Y - will be installing in the auto mode: download all needs, config nginx and others"
echo -n "Do you want to continue? [Y|n]: "
read type

if [ "$type" == "n" ]; then
  exit 0
fi

code=`lsb_release -a | grep Codename | sed 's/[[:space:]]//g' | cut -f2 -d:`

echo
echo "Debian codename:"
echo "$code"
echo

mkdir -p /var/tmp
pushd /var/tmp

echo
echo "Installing Java JDK 1.8"
echo

if [ "$code" != "jessie" ]; then
  echo "from oracle site"
  echo
  url=http://download.oracle.com/otn-pub/java/jdk/8u91-b14/
  java_version=jdk-8u91-linux-x64.tar.gz

  wget -c -O "$java_version" --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "$url$java_version"

  mkdir -p /opt/jdk

  tar -zxf java_version -C /opt/jdk

  update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_91/bin/java 100
  update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_91/bin/javac 100
else
  apt-get install java8-jdk -y
fi;

echo
java -version
update-alternatives --display java
javac -version
update-alternatives --display javac
echo

mkdir -p /usr/jetbrains/{youtrack, hub, upsource, teamcity}

wget http://download.jetbrains.com/hub/2.0/hub-ring-bundle-2.0.244.zip -O /usr/jetbrains/hub/arch.zip

wget http://download.jetbrains.com/charisma/youtrack-6.5.17105.zip -O /usr/jetbrains/youtrack/arch.zip

wget http://download.jetbrains.com/upsource/upsource-3.0.4364.zip -O /usr/jetbrains/upsource/arch.zip

wget http://download.jetbrains.com/teamcity/TeamCity-9.1.7.tar.gz -O /usr/jetbrains/teamcity/arch.tar.gz

pushd /usr/jetbrains/hub
unzip arch.zip
popd

pushd /usr/jetbrains/youtrack
unzip arch.zip
popd

pushd /usr/jetbrains/teamcity
tar -xzvf arch.zip
popd

pushd /usr/jetbrains/upsource
unzip arch.zip
mv Upsource/* ../upsource/
chmod +x -R ../upsource/
popd
popd

