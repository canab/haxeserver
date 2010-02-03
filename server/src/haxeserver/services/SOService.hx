/**
 * ...
 * @author canab
 */

package haxeserver.services;
import haxeserver.core.Application;

class SOService 
{
	public function new() 
	{
	}
	
	public function getSharedObjects(namePrefix:String):Dynamic
	{
		var result:Array<Dynamic> = [];
		for (so in Application.instance.sharedObjects)
		{
			if (namePrefix == null || so.id.indexOf(namePrefix) == 0)
				result.push(so.id);
		}
		return result;
	}
	
}