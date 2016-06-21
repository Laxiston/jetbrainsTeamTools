#!/bin/bash

type="y"
echo "Y - Run installation."
echo -n "Do you want to continue? [Y|n]: "
read type

if [ "$type" == "n" ]; then
  exit 0
fi

echo "*********************************************************************"
echo "In order to continue installing need set a few properties for proxy:"

echo -n "Hub domain url: "
read hubDomain
echo -n "Hub port: "
read hubPort

echo -n "YouTrack domain url: "
read youTrackDomain
echo -n "YouTrack port: "
read youTrackPort

echo -n "UpSource domain url: "
read upSourceDomain
echo -n "UpSource port: "
read upSourcePort

echo -n "Cron E-mail: "
read cronEmail

printParams() {
	echo "*****************************************"
	echo
	echo "Hub domain url: $hubDomain"
	echo "Hub port: $hubPort"
	echo "YouTrack domain url: $youTrackDomain"
	echo "YouTrack port: $youTrackPort"
	echo "UpSource domain url: $upSourceDomain"
	echo "UpSource port: $upSourcePort"
	echo "Cron email: $cronEmail"
	echo
	echo "*****************************************"
}

if [ "$hubDomain" == "" ] || [ "$hubPort" == "" ] || [ "$youTrackDomain" == "" ] || [ "$youTrackPort" == "" ] || [ "$upSourceDomain" == "" ] || [ "$upSourcePort" == "" ] || [ "$cronEmail" == "" ]; then
  echo "You have mistake into parameters!"
  exit 1
fi

printParams

echo -n "Do you continue? [Y|n]"
read type

if [ "$type" == "n" ]; then
  exit 0
fi

mkdir -p /root/crons

cat >/root/crons/jetbrains<<EOF
#!/bin/bash

status=404
while [ \$status -eq 404 ]; do
  echo "wait HUB ..."
  sleep 60
  status=\`curl -s -o /dev/null -w "%{http_code}" http://localhost:${hubPort}/hub/\`
  echo "HUB status \$status"
done

echo "Starting YouTrack ... "
service youtrack start
echo "Starting UpSource ... "
service upsource start

exit 0
EOF

chmod +x /root/crons/jetbrains

echo "MAILTO=$cronEmail" > /tmp/cron_
echo "" >> /tmp/cron_
echo "@reboot /root/crons/jetbrains" > /tmp/cron_
crontab /tmp/cron_

service upsource stop
service youtrack stop
service hub stop

/usr/jetbrains/hub/bin/hub.sh configure --listen-port ${hubPort} --base-url http://${hubDomain}
/usr/jetbrains/youtrack/bin/youtrack.sh configure --listen-port ${youTrackPort} --base-url http://${youTrackDomain}
/usr/jetbrains/upsource/bin/upsource.sh configure --listen-port ${upSourcePort} --base-url http://${upSourceDomain}

service hub start
service youtrack start
service upsource start

echo "************************************************************************************"
echo "Go to setup."
echo ${hubDomain}
echo ${youTrackDomain}
echo ${upSourceDomain}
echo "************************************************************************************"