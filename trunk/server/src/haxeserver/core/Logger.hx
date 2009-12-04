/**
 * ...
 * @author Canab
 */

package haxeserver.core;
import haxe.Log;
import haxe.PosInfos;

class Logger 
{

	public function new() 
	{
	}
	
	public function trace(value:Dynamic)
	{
		neko.Lib.println(value);
	}
	
}