/**
 * ...
 * @author canab
 */

package haxeserver.services;
import haxeserver.RemoteConnection;

class ServiceBase 
{
	static public var defaultConnection:RemoteConnection;
	
	public var connection:RemoteConnection;
	
	private var resultHandler:Dynamic->Void;

	public function new(resultHandler:Dynamic->Void = null) 
	{
		this.resultHandler = resultHandler;
	}
	
	private function doCall(func:String, args:Array<Dynamic>):Void
	{
		var connection:RemoteConnection = getConnection();
		if (connection != null)
		{
			var className:String = Type.getClassName(Type.getClass(this));
			connection.serverAPI.S(className, func, args, resultHandler);
		}
		else
		{
			throw "Connection for this service has not been set.";
		}
	}
	
	private function getConnection():RemoteConnection
	{
		return (connection != null) ? connection : defaultConnection;
	}
}