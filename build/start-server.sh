echo
echo starting server...
start-stop-daemon --start --name haxeserver -b --chdir /var/projects/server --exec /usr/bin/neko server.n
ps aux | grep server.n
echo

