/**
 * ...
 * @author canab
 */

package haxelib.test;
import haxe.PosInfos;
import haxe.Stack;

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
	
	private function fail():Void 
	{
		success = false;
		
		var stack:Array<StackItem> = Stack.callStack();
		stack.shift();
		stack.shift();
		for (item in stack)
		{
			var itemText:String = cast item;
			var re:EReg = ~/FilePos|Method|\(|\)/g;
			itemText = re.replace(itemText, '');
			trace(itemText);
		}
	}
	
	private function assertTrue(value:Bool):Void 
	{
		if (!(value == true))
			fail();
	}
	
	private function assertFalse(value:Bool):Void 
	{
		if (!(value == false))
			fail();
	}
	
	private function assertEquals(array1:Array<Dynamic>, array2:Array<Dynamic>):Void 
	{
		if (array1.length != array2.length)
		{
			fail();
		}
		else
		{
			for (i in 0...array1.length - 1)
			{
				if (array1[i] != array2[i])
				{
					fail();
					break;
				}
			}
		}
	}
}