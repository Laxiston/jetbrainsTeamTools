#!/bin/bash

type="y"
echo "Y - Run JDK installation."
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

existingJava=`java -version | grep "java version \"1.8.0_91\""`

echo ${existingJava}

mkdir -p /var/tmp
pushd /var/tmp

echo
echo "Installing Java JDK 1.8 for $code"
echo

if [ "$code" != "jessie" ]; then
#    if [ "$existing_java" == "n" ]; then
#    continue;
#    fi
  echo "From oracle"
  echo
  url=http://download.oracle.com/otn-pub/java/jdk/8u91-b14/
  javaVersion=jdk-8u91-linux-x64.tar.gz

  wget -c -O "$javaVersion" --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "$url$javaVersion"

  mkdir -p /opt/jdk

  tar -zxf ${javaVersion} -C /opt/jdk

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

echo " JDK installed."