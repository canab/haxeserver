/**
 * ...
 * @author canab
 */

package haxeserver.test.data;

class PlayerData 
{
	public var name:String;
	public var health:Int;
	public var active:Bool;
	public var array:Array<Dynamic>;

	public function new() 
	{
		name = "chlos";
		health = 100;
		active = true;
		array = [name, health, active];
	}
	
	public function toString():String
	{
		return 'PlayerData: ' + [name, health, active, array];
	}
}