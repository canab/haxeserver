#!/bin/sh

NAME=haxeserver
PIDFILE=/var/projects/haxeServer/$NAME.pid
HOMEDIR=/var/projects/haxeServer
COMMAND="/usr/local/bin/neko $HOMEDIR/server.n"
BUILD_ID=dontKillMe #for hudson

d_start() {
	echo "Starting $NAME:"
	start-stop-daemon --start --background --make-pidfile --pidfile $PIDFILE --chdir $HOMEDIR --exec $COMMAND
	#start-stop-daemon --start             --make-pidfile --pidfile $PIDFILE --chdir $HOMEDIR --exec $COMMAND
	echo "."
}

d_stop() {
	echo "Stopping $NAME:"
	start-stop-daemon --stop --pidfile $PIDFILE
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
