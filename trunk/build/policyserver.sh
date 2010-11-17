#!/bin/sh

NAME=policyserver
PIDFILE=/var/projects/haxeserver/$NAME.pid
HOMEDIR=/projects/haxeserver/policyserver
COMMAND="/usr/local/bin/neko $HOMEDIR/fpserver.n 109.74.195.118 843 crossdomain.xml"

d_start() {
	echo "Starting $NAME:"
	start-stop-daemon --start --quiet --background --make-pidfile --pidfile $PIDFILE --chdir $HOMEDIR --exec $COMMAND
	echo "."
}

d_stop() {
	echo "Stopping $NAME:"
	start-stop-daemon --stop --quiet --pidfile $PIDFILE
	if [ -e $PIDFILE ]
		then rm $PIDFILE
	fi
	echo "."
}

case $1 in
	start)
	d_start
	;;
	stop)
	d_stop
	;;
	restart)
	d_stop
	sleep 1
	d_start
	;;
	*)
echo "usage: $NAME {start|stop|restart}"
	exit 1
	;;
esac

exit 0
