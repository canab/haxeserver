/**
 * ...
 * @author canab
 */

package haxeserver.services;

class AdminService extends ServiceBase
{

	public function new(onResult:Dynamic->Void = null, onError:Dynamic->Void = null) 
	{
		super(onResult, onError);
	}
	
	public function getGeneral():Void
	{
		doCall("getGeneral", []);
	}
	
}