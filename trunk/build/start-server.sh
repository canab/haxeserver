echo starting haxe server
start-stop-daemon --start -b --chdir /var/projects/server --exec /usr/bin/neko server.n
ps aux | grep server.n