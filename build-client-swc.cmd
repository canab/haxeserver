@del client\bin\remote-lib.swc
haxe -cp client\src -debug -cp library -swf client\bin\remote-lib.swc -swf-version 10 haxeserver.Library
pause