/**
 * ...
 * @author canab
 */

package haxeserver.services;

class AdminService extends ServiceBase
{

	public function new(onResult:Dynamic->Void = null) 
	{
		super(onResult);
	}
	
	public function getGeneral():Void
	{
		doCall("getGeneral", []);
	}
	
	public function getProfilerData():Void
	{
		doCall("getProfilerData", []);
	}
	
}