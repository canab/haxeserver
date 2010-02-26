package ;

import flash.events.Event;
import flash.Lib;
import haxelib.test.Test;
import haxelib.test.TestSuite;
import haxeserver.RemoteConnection;
import haxeserver.test.data.ItemData;
import haxeserver.test.data.PlayerData;
import haxeserver.test.data.SampleCommand;
import haxeserver.test.SOTest;


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
	public var remoteId(default, null):String;
	
	private var suite:TestSuite;
	
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
		connection1 = createConnection();
		connection2 = createConnection();
	}
	
	private function createConnection():RemoteConnection
	{
		var connection:RemoteConnection = new RemoteConnection();
		connection.host = HOST;
		connection.port = PORT;
		connection.connectEvent.addListener(onConnect);
		connection.errorEvent.addListener(onError);
		connection.connect();
		connection.registerClass(PlayerData);
		connection.registerClass(ItemData);
		connection.registerClass(SampleCommand);
		return connection;
	}
	
	private function onError(sender:RemoteConnection):Void
	{
		trace(sender.errorMessage);
	}
	
	private function onConnect(sender:RemoteConnection):Void
	{
		trace('Connected to ' + sender.host + ':' + sender.port);
		if (connection1.connected && connection2.connected)
		{
			remoteId = 'SO' + Std.string(connection1.userId);
			Lib.current.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		Lib.current.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		createTests();
	}
	
	private function createTests():Void
	{
		suite = new TestSuite();
		suite.completeEvent.addListener(onComplete);
		suite.add(new SOTest());
		//suite.add(new SOUserOrderTest());
		suite.run();
	}
	
	private function onComplete(sender:TestSuite):Void
	{
		trace('------------------------');
		if (suite.succes)
			trace('SUCCESSFUL');
		else
			trace('FAILED');
			
		Lib.current.addEventListener(Event.ENTER_FRAME, repeat);
	}
	
	private function repeat(e:Event):Void 
	{
		Lib.current.removeEventListener(Event.ENTER_FRAME, repeat);
		connection1.disconnect();
		connection2.disconnect();
		//if (suite.succes)
			//initialize();
	}
	
}