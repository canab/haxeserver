package ;

import flash.Lib;
import haxeserver.RemoteConnection;

/**
 * ...
 * @author canab
 */

class Main 
{
	static public var HOST:String = 'localhost';
	static public var PORT:Int = 8080;
	
	static public var instance(default, null):Main;
	
	public var connection1(default, null):RemoteConnection;
	public var connection2(default, null):RemoteConnection;
	
	static function main() 
	{
		instance = new Main();
	}
	
	public function new():Void 
	{
		initialize();
	}
	
	private function initialize():Void
	{
		connection1 = new RemoteConnection();
		connection1.host = HOST;
		connection1.port = PORT;
		connection1.connectEvent.addListener(onConnect);
		connection1.errorEvent.addListener(onError);
		connection1.connect();
		
		connection2 = new RemoteConnection();
		connection2.host = HOST;
		connection2.port = PORT;
		connection2.connectEvent.addListener(onConnect);
		connection2.errorEvent.addListener(onError);
		connection2.connect();		
	}
	
	private function onError(sender:RemoteConnection):Void
	{
		trace(sender.errorMessage);
	}
	
	private function onConnect(sender:RemoteConnection):Void
	{
		if (connection1.connected && connection2.connected)
		{
			createTests();
		}
	}
	
	private function createTests():Void
	{
		
	}
	
}