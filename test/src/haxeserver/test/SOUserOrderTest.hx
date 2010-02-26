/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.IRemoteClient;
import haxeserver.RemoteClient;
import haxeserver.RemoteObject;
import haxeserver.test.data.SampleCommand;

class SOUserOrderTest extends AsincTest, implements IRemoteClient
{
	private var myRemote:RemoteObject;
	private var otherRemote:RemoteObject;
	private var tryCount:Int;
	private var tryNum:Int;

	public function new() 
	{
		tryCount = 10;
		tryNum = 0;
		super();
	}

	override public function initialize():Void
	{
		runTest();
	}
	
	private function runTest():Void
	{
		trace("==========================================");
		
		myRemote = Main.instance.connection1.getRemoteObject(Main.instance.remoteId);
		myRemote.connect(this);
		
		otherRemote = Main.instance.connection2.getRemoteObject(Main.instance.remoteId);
		otherRemote.connect(new RemoteClient());
	}
	
	
	override public function dispose():Void
	{
	}
	
	public function onReady():Void
	{
		trace('ready:' + Main.instance.connection1.userId);
	}
	
	public function onUserConnect(userId:Int):Void
	{
		if (myRemote.users.length == 2)
		{
			myRemote.sendCommand(new SampleCommand());
		}
	}
	
	public function onUserDisconnect(userId:Int):Void
	{
	}
	
	public function onStateCreated(stateId:String, state:Dynamic):Void
	{
	}
	
	public function onStateChanged(stateId:String, state:Dynamic):Void
	{
	}
	
	public function onStateRemoved(stateId:String, state:Dynamic):Void
	{
	}
	
	public function onSharedObjectFull():Void
	{
	}
	
	public function onCommand(command:Dynamic):Void
	{
		assertEquals(myRemote.users, otherRemote.users);
			
		myRemote.disconnect();
		otherRemote.disconnect();
		
		if (success)
		{
			if (++tryNum < tryCount)
				runTest();
			else
				dispatchComplete();
		}
		else
		{
			trace('attempt:' + tryNum);
			trace(myRemote.users);
			trace(otherRemote.users);
			dispatchComplete();
		}
	}
}