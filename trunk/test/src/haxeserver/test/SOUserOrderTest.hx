package haxeserver.test;

import haxelib.test.AsincTest;
import haxeserver.so.IRemoteClient;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;
/**
 * ...
 * @author canab
 */

class SOUserOrderTest extends AsincTest, implements IRemoteClient
{
	private var myRemote:RemoteObject;
	private var otherRemote:RemoteObject;
	private var anotherRemote:RemoteObject;

	public function new() 
	{
		super();
	}

	override public function initialize():Void
	{
		var remoteId:String = "OrderTest" + Main.instance.connection1.userId + "_" + tryNum;
		
		myRemote = new RemoteObject(remoteId);
		myRemote.connect(Main.instance.connection1, this);
		
		otherRemote = new RemoteObject(remoteId);
		otherRemote.connect(Main.instance.connection2, this);
		
		anotherRemote = new RemoteObject(remoteId);
		anotherRemote.connect(Main.instance.connection3, this);
	}
	
	override public function dispose():Void 
	{
		myRemote.disconnect();
		otherRemote.disconnect();
	}
	
	public function onReady():Void
	{
	}
	
	public function onUserConnect(userId:Int):Void
	{
		if (myRemote.users.length == 3
		 && otherRemote.users.length == 3
		 && anotherRemote.users.length == 3)
		{
			assertArrayEquals(myRemote.users, otherRemote.users);
			assertArrayEquals(myRemote.users, anotherRemote.users);
			anotherRemote.disconnect();
		}
	}
	
	public function onUserDisconnect(userId:Int):Void
	{
		if (myRemote.users.length == 2 && otherRemote.users.length == 2)
		{
			assertArrayEquals(myRemote.users, otherRemote.users);
			dispatchComplete();
		}
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
	}
	
}