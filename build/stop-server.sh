echo
echo stopping server...
start-stop-daemon --stop --exec /usr/bin/neko server.n
ps aux | grep server.n
echo

