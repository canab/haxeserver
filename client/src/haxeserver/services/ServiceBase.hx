/**
 * ...
 * @author canab
 */

package haxeserver.services;
import haxeserver.RemoteConnection;

class ServiceBase 
{
	static public var defaultConnection:RemoteConnection;
	static public var defaultErrorHandler:Dynamic->Void;
	
	private var resultHandler:Dynamic->Void;
	private var errorHandler:Dynamic->Void;

	public function new(resultHandler:Dynamic->Void = null, errorHandler:Dynamic->Void = null) 
	{
		this.resultHandler = resultHandler;
		this.errorHandler = errorHandler;
	}
	
	private function doCall(func:String, args:Array<Dynamic>):Void
	{
		var className:String = Type.getClassName(Type.getClass(this));
		getConnection().serverAPI.callService(className, func, args, resultHandler);
	}
	
	private function getConnection():RemoteConnection
	{
		return defaultConnection;
	}
}