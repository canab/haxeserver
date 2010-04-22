/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;
import haxeserver.test.data.PlayerData;


private class MyClient extends RemoteClient
{
	private var test:SOAutoRemoveStateTest;
	private var remote:RemoteObject;

	public function new(remote:RemoteObject, test:SOAutoRemoveStateTest):Void 
	{
		this.remote = remote;
		this.test = test;
		super();
	}
	
	override public function onReady():Void 
	{
		remote.createState('P', new PlayerData(), true);
	}
	
	override public function onStateCreated(stateId:String, state:Dynamic):Void 
	{
		test.connectOtherClient();
	}
}

private class OtherClient extends RemoteClient
{
	private var test:SOAutoRemoveStateTest;
	private var remote:RemoteObject;
	
	public function new(remote:RemoteObject, test:SOAutoRemoveStateTest):Void 
	{
		this.remote = remote;
		this.test = test;
		super();
	}
	
	override public function onReady():Void 
	{
		test.disconnectFirstClient();
	}
	
	override public function onUserDisconnect(userId:Int):Void 
	{
		//trace('user disconnected' + userId);
	}
	
	override public function onStateRemoved(stateId:String, state:Dynamic):Void 
	{
		test.complete();
	}
	
}

class SOAutoRemoveStateTest extends AsincTest
{
	static private var playerStateId:String = 'P';
	static private var player:PlayerData = new PlayerData();
	
	private var myRemote:RemoteObject;
	private var otherRemote:RemoteObject;
	private var remoteId:String;
	
	public function new() 
	{
		super();
	}
	
	override public function initialize():Void
	{
		remoteId = "RemoveStateTest" + Main.instance.connection1.userId + '_' + tryNum;
		myRemote = new RemoteObject(remoteId);
		myRemote.connect(Main.instance.connection1, new MyClient(myRemote, this));
	}
	
	public function connectOtherClient():Void 
	{
		otherRemote = new RemoteObject(remoteId);
		otherRemote.connect(Main.instance.connection2, new OtherClient(otherRemote, this));
	}
	
	public function disconnectFirstClient():Void 
	{
		myRemote.disconnect();
	}
	
	public function complete():Void 
	{
		dispatchComplete();
	}
}