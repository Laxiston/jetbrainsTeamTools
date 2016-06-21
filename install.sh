#!/bin/bash


apt-get install mc htop git unzip wget curl -y

echo
echo "********************************************************************************"
echo "*                                                                              *"
echo "*                                                                              *"
echo "*                                  WELCOME                                     *"
echo "*                                                                              *"
echo "*                                                                              *"
echo "********************************************************************************"
echo
echo "Hub"
echo "Download https://www.jetbrains.com/hub/download/"
echo "Guide https://www.jetbrains.com/help/hub/2.0/Introduction-to-HUB.html"
echo "Extract into /usr/jetbrains/hub/"
echo "************************************************************************************************************************************************"
echo
echo "YouTrack"
echo "Download https://www.jetbrains.com/youtrack/download/get_youtrack.html"
echo "Guide https://confluence.jetbrains.com/display/YTD65/Installing+YouTrack+with+ZIP+Distribution"
echo "Extract into /usr/jetbrains/youtrack/"
echo "************************************************************************************************************************************************"
echo
echo "Upsource"
echo "Download https://www.jetbrains.com/upsource/download/"
echo "Guide https://www.jetbrains.com/help/upsource/3.0/getting-started-with-upsource.html"
echo "Extract into /usr/jetbrains/upsource/"
echo "************************************************************************************************************************************************"
echo
echo "TeamCity"
echo "Download https://www.jetbrains.com/teamcity/download/"
echo "Guide https://confluence.jetbrains.com/display/TCD9/Installing+and+Configuring+the+TeamCity+Server"
echo "Extract into /usr/jetbrains/teamcity/"
echo "************************************************************************************************************************************************"


type="y"
echo "Y - Run installation."
echo -n "Do you want to continue? [Y|n]: "
read type

if [ "$type" == "n" ]; then
  exit 0
fi