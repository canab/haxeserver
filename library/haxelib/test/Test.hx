/**
 * ...
 * @author canab
 */

package haxelib.test;

class Test 
{
	public var success(default, null):Bool;

	public function new() 
	{
		success = true;
	}
	
	public function initialize():Void 
	{
	}
	
	public function dispose():Void 
	{
	}
	
	private function assertTrue(value:Bool):Void 
	{
		if (!(value == true))
			success = false;
	}
	
	private function assertFalse(value:Bool):Void 
	{
		if (!(value == false))
			success = false;
	}
	
	private function assertEquals(value1:Dynamic, value2:Dynamic):Void 
	{
		if (!(value1 == value2))
			success = false;
	}
	
	private function assertNotEquals(value1:Dynamic, value2:Dynamic):Void 
	{
		if (!(value1 != value2))
			success = false;
	}
	
}