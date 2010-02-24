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
		success = (value == true);
	}
	
	private function assertFalse(value:Bool):Void 
	{
		success = (value == false);
	}
	
	private function assertEquals(value1:Dynamic, value2:Dynamic):Void 
	{
		success = (value1 == value2);
	}
	
	private function assertNotEquals(value1:Dynamic, value2:Dynamic):Void 
	{
		success = (value1 != value2);
	}
	
}