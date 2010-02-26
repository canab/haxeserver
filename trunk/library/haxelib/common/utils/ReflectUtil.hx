/**
 * ...
 * @author Canab
 */

package haxelib.common.utils;

class ReflectUtil 
{
	static public function getFieldsAndProperties(object:Dynamic):Array<String>
	{
		var objectClass:Class<Dynamic> = Type.getClass(object);
		var fields:Array<String> = Reflect.fields(object);
		if (objectClass != null)
			fields  = fields.concat(Type.getInstanceFields(objectClass));
			
		var result:Array<String> = [];
		for (field in fields)
		{
			var fieldValue:Dynamic = Reflect.field(object, field);
			if (!Reflect.isFunction(fieldValue))
				result.push(field);
		}
		
		return result;
	}
	
	static public function copyFields(source:Dynamic, target:Dynamic):Void 
	{
		var fields:Array<String> = getFieldsAndProperties(source);
		for (field in fields)
		{
			Reflect.setField(target, field, Reflect.field(source, field));
		}
	}
	
}