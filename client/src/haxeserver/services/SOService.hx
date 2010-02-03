/**
 * ...
 * @author canab
 */

package haxeserver.services;

class SOService extends ServiceBase
{
	public function new(onResult:Dynamic->Void = null, onError:Dynamic->Void = null) 
	{
		super(onResult, onError);
	}
	
	public function getSharedObjects(prefix:String = null)
	{
		doCall("getSharedObjects", [prefix]);
	}
	
}