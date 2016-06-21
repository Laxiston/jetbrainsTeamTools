#!/bin/bash

buildInitD() {

  echo "Making init.d for $1"

  rq="hub "
  if [ "$1" == "hub" ]; then
    rq=""
  fi

  cat >/etc/init.d/$1 <<EOF
#! /bin/sh
### BEGIN INIT INFO
# Provides:          $1
# Required-Start:    ${rq}\$local_fs \$remote_fs \$network \$syslog \$named
# Required-Stop:     ${rq}\$local_fs \$remote_fs \$network \$syslog \$named
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: initscript for $1
# Description:       initscript for $1
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
NAME=$1
SCRIPT=/usr/jetbrains/\$NAME/bin/\$NAME.sh

do_start() {
  \$SCRIPT start soft
}

case "\$1" in
  start)
    do_start
    ;;
  stop|restart|status|run|rerun|help)
    \$SCRIPT \$1 \$2
    ;;
  *)
    echo "Usage: sudo /etc/init.d/$1 {start|stop|restart|status|run|rerun}" >&2
    exit 1
    ;;
esac

exit 0
EOF

  chmod +x /etc/init.d/$1

  update-rc.d $1 defaults
  if [ "$1" != "hub" ]; then
    update-rc.d $1 disable
  fi
}

echo
buildInitD youtrack
echo "Building YouTrack initialization script is completed."
echo
buildInitD hub
echo "Building Hub initialization script is completed."
echo
buildInitD upsource
echo "Building UpSource initialization script is completed."

echo "BUILDING SUCCESSFULLY COMPLETED."