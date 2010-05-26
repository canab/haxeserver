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
	
	public function getSharedObjects(prefix:String = null):Void
	{
		doCall("getSharedObjects", [prefix]);
	}
	
	public function createSharedObject(prefix:String, maxUsers:Int):Void
	{
		doCall("createSharedObject", [prefix, maxUsers]);
	}
}