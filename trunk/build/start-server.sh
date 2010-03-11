echo starting haxe server
echo ...
start-stop-daemon --start -b --chdir /var/projects/server --exec /usr/bin/neko server.n
ps aux | grep server.n
