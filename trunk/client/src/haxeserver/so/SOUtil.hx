/**
 * ...
 * @author canab
 */

package haxeserver.so;

import haxelib.common.utils.ArrayUtil;
import haxelib.common.utils.ReflectUtil;

class SOUtil 
{
	public function new() 
	{
	}
	
	// TODO cache fields
	static public function getObjectData(object:Dynamic):Array<Dynamic>
	{
		var fields:Array<String> = ReflectUtil.getFieldsAndProperties(object);
		ArrayUtil.sortStrings(fields);
		
		var values:Array<Dynamic> = [];
		for (i in 0...fields.length)
		{
			values.push(Reflect.field(object, fields[i]));
		}
		return values;
	}
	
	static public function restoreObject(object:Dynamic, objectData:Array<Dynamic>):Void
	{
		var fields:Array<String> = ReflectUtil.getFieldsAndProperties(object);
		ArrayUtil.sortStrings(fields);
		
		for (i in 0...objectData.length)
		{
			Reflect.setField(object, fields[i], objectData[i]);
		}
	}
	
	static public function getUpdateData(object:Dynamic, changeData:Dynamic):Array<Dynamic>
	{
		var fields:Array<String> = ReflectUtil.getFieldsAndProperties(object);
		ArrayUtil.sortStrings(fields);
		
		var updateData:Array<Dynamic> = [];
		for (i in 0...fields.length)
		{
			if (Reflect.hasField(changeData, fields[i]))
			{
				updateData.push(i);
				updateData.push(Reflect.field(changeData, fields[i]));
			}
		}
		return updateData;
	}
	
	static public function updateObject(object:Dynamic, updateData:Array<Dynamic>):Void
	{
		var fields:Array<String> = ReflectUtil.getFieldsAndProperties(object);
		ArrayUtil.sortStrings(fields);
		
		for (i in 0...Std.int(updateData.length / 2))
		{
			var field:String = fields[updateData[2 * i]];
			var value:Dynamic = updateData[2 * i + 1];
			Reflect.setField(object, field, value);
		}
	}
	
}