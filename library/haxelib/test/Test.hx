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
	public var tryNum:Int;
	public var tryCount:Int;

	public function new() 
	{
		success = true;
		tryNum = 0;
		tryCount = 1;
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
	
	private function assertEquals(value1:Dynamic, value2:Dynamic):Void 
	{
		if (!(value1 == value2))
		{
			trace("assertEquals failed");
			trace("value1=" + value1);
			trace("value2=" + value2);
			fail();
		}
	}
	
	private function assertTrue(value:Bool):Void 
	{
		if (!(value))
		{
			trace("assertTrue failed");
			fail();
		}
	}
	
	private function assertFalse(value:Bool):Void 
	{
		if (value)
		{
			trace("assertFalse failed");
			fail();
		}
	}
	
	private function assertArrayEquals(array1:Array<Dynamic>, array2:Array<Dynamic>):Void 
	{
		var result:Bool = true;
		if (array1.length != array2.length)
		{
			result = false;
		}
		else
		{
			for (i in 0...array1.length - 1)
			{
				if (array1[i] != array2[i])
				{
					result = false;
					break;
				}
			}
		}
		if (!result)
		{
			trace("assertArrayEquals failed");
			trace("value1=" + array1);
			trace("value2=" + array2);
			fail();
		}
	}
}