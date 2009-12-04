/**
 * ...
 * @author Canab
 */

package haxelib.utils;

class ArrayUtil 
{
	static public function getItemIndex(array:Array<Dynamic>, item:Dynamic):Void 
	{
		var length:Int = array.length;
		for (i in 1...length)
		{
			if (array[i] == item)
				return i;
		}
		return -1;
	}

	
}