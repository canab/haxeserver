/**
 * ...
 * @author canab
 */

package haxeserver.services;

class SOService extends ServiceBase
{
	public function new(onResult:Dynamic->Void = null) 
	{
		super(onResult);
	}
	
	public function connectToFreeSO(soPrefix:String, maxUsers:Int):Void 
	{
		doCall("connectToFreeSO", [soPrefix, maxUsers]);
	}
	
	public function getSharedObjects(prefix:String = null, haveFreeSlots:Bool = false):Void
	{
		doCall("getSharedObjects", [prefix, haveFreeSlots]);
	}
	
	public function createSharedObject(prefix:String, maxUsers:Int = 0, name:String = null):Void
	{
		doCall("createSharedObject", [prefix, maxUsers, name]);
	}
	
	public function setUnconnectable(soId:String):Void 
	{
		doCall("setUnconnectable", [soId]);
	}
}