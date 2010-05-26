package ;

import flash.events.Event;
import flash.Lib;
import haxelib.test.Test;
import haxelib.test.TestSuite;
import haxeserver.RemoteConnection;
import haxeserver.services.ServiceBase;
import haxeserver.test.AdminServiceTest;
import haxeserver.test.data.ItemData;
import haxeserver.test.data.PlayerData;
import haxeserver.test.data.SampleCommand;
import haxeserver.test.LoginServiceTest;
import haxeserver.test.SOAutoConnectTest;
import haxeserver.test.SOAutoRemoveStateTest;
import haxeserver.test.SOBaseTest;
import haxeserver.test.SOCreateTest;
import haxeserver.test.SOLockTest;
import haxeserver.test.SOMaxUsersTest;
import haxeserver.test.SORestoreTest;
import haxeserver.test.SOServiceTest;
import haxeserver.test.SOUserOrderTest;

/**
 * ...
 * @author canab
 */

class Main 
{
	static public var HOST:String = 'localhost';
	//static public var HOST:String = '173.203.115.146';
	static public var PORT:Int = 8081;
	
	static public var LOOP:Bool = true;
	static public var TRY_COUNT:Int = 2;
	
	static public var instance(default, null):Main;
	
	public var connection1(default, null):RemoteConnection;
	public var connection2(default, null):RemoteConnection;
	public var connection3(default, null):RemoteConnection;
	public var instanceId(default, null):String;
	
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
		connection3 = createConnection();
		
		ServiceBase.defaultConnection = connection1;
	}
	
	private function createTests():Void
	{
		suite = new TestSuite();
		suite.completeEvent.addListener(onComplete);
		
/*		suite.add(new SOBaseTest(), TRY_COUNT);
		suite.add(new SOAutoRemoveStateTest(), TRY_COUNT);
		suite.add(new SORestoreTest(), TRY_COUNT);
		suite.add(new SOUserOrderTest(), TRY_COUNT);
		suite.add(new SOLockTest(), TRY_COUNT);
		suite.add(new SOMaxUsersTest(), TRY_COUNT);
		suite.add(new LoginServiceTest(), TRY_COUNT);
		suite.add(new SOServiceTest(), TRY_COUNT);
		suite.add(new SOAutoConnectTest(), TRY_COUNT);
		suite.add(new AdminServiceTest(), TRY_COUNT);
*/		
		suite.add(new SOCreateTest(), TRY_COUNT);
		
		suite.run();
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
		if (connection1.connected
			&& connection2.connected
			&& connection3.connected)
		{
			Lib.current.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		Lib.current.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		createTests();
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
		connection3.disconnect();
		if (suite.succes && LOOP)
			initialize();
	}
	
}