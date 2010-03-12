echo
echo stopping server...
start-stop-daemon --stop --name haxeserver --exec /usr/bin/neko server.n
ps aux | grep server.n
echo

