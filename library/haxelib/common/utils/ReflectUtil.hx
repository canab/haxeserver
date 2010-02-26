/**
 * ...
 * @author Canab
 */

package haxelib.common.utils;

class ReflectUtil 
{
	
	static public function copyFields(source:Dynamic, target:Dynamic):Void 
	{
		var fields:Array<String> = null;
		var sourceClass:Class<Dynamic> = Type.getClass(source);
		if (sourceClass == null)
			fields = Reflect.fields(source);
		else
			fields = Type.getInstanceFields(sourceClass);
			
		for (field in fields)
		{
			var sourceValue:Dynamic = Reflect.field(source, field);
			if (!Reflect.isFunction(sourceValue))
				Reflect.setField(target, field, sourceValue);
		}
	}
	
}