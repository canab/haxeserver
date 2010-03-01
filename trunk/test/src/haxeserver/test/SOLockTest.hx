/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;

private class MyClient extends RemoteClient
{
	private var test:SOLockTest;
	private var remote:RemoteObject;
	
	public function new(test:SOLockTest, remote:RemoteObject):Void 
	{
		super();
		this.test = test;
		this.remote = remote;
	}
}

private class OtherClient extends RemoteClient
{
	private var test:SOLockTest;
	private var remote:RemoteObject;
	
	public function new(test:SOLockTest, remote:RemoteObject):Void 
	{
		super();
		this.test = test;
		this.remote = remote;
	}
}


class SOLockTest extends AsincTest
{
	private var myRemote:RemoteObject;
	private var myClient:MyClient;
	
	private var otherRemote:RemoteObject;
	private var otherClient:OtherClient;

	public function new()
	{
		super();
	}
	
	override public function initialize():Void 
	{
		var remoteId:String = "LockTest" + Main.instance.connection1.userId + "_" + tryNum;
		
		myRemote = new RemoteObject(remoteId);
		myClient = new MyClient(this, myRemote);
		myRemote.connect(Main.instance.connection1, myClient);
		
		otherRemote = new RemoteObject(remoteId);
		otherClient = new OtherClient(this, otherRemote);
		otherRemote.connect(Main.instance.connection2, otherClient);
	}
	
}