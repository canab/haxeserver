package haxelib.utils {
	public class ReflectUtil {
		static public function copyFields(source : *,target : *) : void {
			var fields : Array = null;
			var sourceClass : Class = Type.getClass(source);
			if(sourceClass == null) fields = Reflect.fields(source);
			else fields = Type.getInstanceFields(sourceClass);
			{
				var _g : int = 0;
				while(_g < fields.length) {
					var field : String = fields[_g];
					++_g;
					var sourceValue : * = Reflect.field(source,field);
					if(!Reflect.isFunction(sourceValue)) Reflect.setField(target,field,sourceValue);
				}
			}
		}
		
	}
}
