/**
 * ...
 * @author canab
 */

package haxeserver.sharedObjects;
import haxelib.common.utils.ArrayUtil;

class SOUtil 
{
	public function new() 
	{
	}
	
	// TODO cache fields
	static public function getObjectData(object:Dynamic):Array<Dynamic>
	{
		var objectClass:Class<Dynamic> = Type.getClass(object);
		var fields:Array<String> = Type.getInstanceFields(objectClass);
		ArrayUtil.sortStrings(fields);
		var values:Array<Dynamic> = [];
		
		for (i in 0...fields.length-1)
		{
			values.push(Reflect.field(object, fields[i]));
		}
		
		return values;
	}
	
	// TODO cache fields
	static public function restoreObject(object:Dynamic, objectData:Array<Dynamic>):Void
	{
		var objectClass:Class<Dynamic> = Type.getClass(object);
		var fields:Array<String> = Type.getInstanceFields(objectClass);
		ArrayUtil.sortStrings(fields);
		
		for (i in 0...objectData.length-1)
		{
			Reflect.setField(object, fields[i], objectData[i]);
		}
	}
	
}