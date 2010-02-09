/**
 * ...
 * @author canab
 */

package haxeserver.services;
import haxeserver.core.Application;

class SOService extends ServiceBase
{
	public function new() 
	{
		super();
	}
	
	public function connectToFreeSO(soPrefix:String, maxUsers:Int):String
	{
		var remoteId:String = "";
		return remoteId;
	}
	
	public function getSharedObjects(namePrefix:String):Array<Dynamic>
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