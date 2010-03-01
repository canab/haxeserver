/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;

private class TestClient extends RemoteClient
{
	public function new():Void 
	{
		super();
	}
	
	dynamic public function readyHandler():Void { }
	dynamic public function userDisconnectHandler():Void { }
	
	
	override public function onReady():Void 
	{
		readyHandler();
	}
	
	override public function onUserDisconnect(userId:Int):Void 
	{
		userDisconnectHandler();
	}
}

class SOMaxUsersTest extends AsincTest
{
	private var remote1:RemoteObject;
	private var remote2:RemoteObject;
	private var remote3:RemoteObject;
	
	private var flag:Bool;
	
	public function new() 
	{
		super();
	}
	
	override public function initialize():Void 
	{
		var remoteId = "TestMaxUsers" + Main.instance.connection1.userId + "_" + tryNum;
		
		var client1:TestClient = new TestClient();
		client1.readyHandler = onClient1Ready;
		client1.userDisconnectHandler = onUserDisconnect;
		
		remote1 = new RemoteObject(remoteId, 2);
		remote1.connect(Main.instance.connection1, client1);
		
		remote2 = new RemoteObject(remoteId);
		
		remote3 = new RemoteObject(remoteId);
	}
	override public function dispose():Void 
	{
		if (remote1.connected)
			remote1.disconnect();
		if (remote2.connected)
			remote2.disconnect();
		if (remote3.connected)
			remote3.disconnect();
	}
	
	private function onClient1Ready():Void
	{
		assertEquals(remote1.connected, true);
		
		flag = false;
		
		var client2:TestClient = new TestClient();
		client2.readyHandler = onNextClientReady;
		remote2.connect(Main.instance.connection2, client2);
		
		var client3:TestClient = new TestClient();
		client3.readyHandler = onNextClientReady;
		remote3.connect(Main.instance.connection3, client3);
	}
	
	private function onNextClientReady():Void
	{
		if (!flag)
		{
			flag = true;
		}
		else
		{
			if (remote2.connected)
			{
				remote2.disconnect();
				assertEquals(remote3.connected, false);
			}
			else
			{
				remote3.disconnect();
				assertEquals(remote2.connected, false);
			}
		}
	}
	
	private function onUserDisconnect():Void 
	{
		var client = new TestClient();
		client.readyHandler = testReady;
		remote2.connect(Main.instance.connection2, client);
	}
	
	private function testReady():Void
	{
		assertEquals(remote2.connected, true);
		dispatchComplete();
	}
}