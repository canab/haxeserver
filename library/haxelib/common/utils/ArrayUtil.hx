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
}