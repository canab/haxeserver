del remote-lib.swc
haxe -cp client\src -cp library -swf9 bin\remote-lib.swc haxeserver.Library
copy bin\remote-lib.swc ..\game_papergame\lib
pause