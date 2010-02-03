del remote-lib.swc
haxe -cp client\src -cp library -swf9 remote-lib.swc haxeserver.Library
copy remote-lib.swc ..\game_papergame\lib
pause