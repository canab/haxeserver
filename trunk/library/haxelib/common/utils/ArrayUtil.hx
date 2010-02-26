/**
 * ...
 * @author Canab
 */

package haxelib.common.utils;

class ArrayUtil 
{
	public function new() 
	{
	}
	
	static public function indexOf(array:Array<Dynamic>, item:Dynamic):Int
	{
		for (i in 0...array.length)
		{
			if (array[i] == item)
				return i;
		}
		return -1;
	}
	
	static public function contains(array:Array<Dynamic>, item:Dynamic):Bool
	{
		return indexOf(array, item) >= 0;
	}
	
	static public function getLength(iterable:Iterable<Dynamic>):Int
	{
		var length:Int = 0;
		var iterator = iterable.iterator();
		while (iterator.hasNext())
		{
			length++;
			iterator.next();
		}
		return length;
	}
	
	static public function sortStrings(array:Array<String>):Void
	{
		array.sort(
			function(string1:String, string2:String):Int
			{
				if (string1 > string2)
					return 1;
				else if (string1 < string2)
					return - 1;
				else
					return 0;
			}
		);
	}
	
}