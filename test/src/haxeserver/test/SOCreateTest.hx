/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.services.SOService;
import haxeserver.so.IRemoteClient;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;

class SOCreateTest extends AsincTest, implements IRemoteClient
{
	private var remoteId:String;
	private var maxUsers:Int;
	private var remote:RemoteObject;

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void 
	{
		remoteId = "SOCreateTest" + Main.instance.connection1.userId + "_" + tryNum;
		maxUsers = 2;
		
		var service:SOService = new SOService(onResult);
		service.connection = Main.instance.connection1;
		service.createSharedObject(remoteId, maxUsers);
	}
	
	private function onResult(result:String):Void
	{
		remote = new RemoteObject(result);
		remote.connect(Main.instance.connection1, this);
	}
	
	/* INTERFACE haxeserver.so.IRemoteClient */
	
	public function onReady():Void
	{
		assertEquals(remote.users.length, 1);
		assertEquals(remote.maxUsers, maxUsers);
		remote.disconnect();
		dispatchComplete();
	}
	
	public function onUserConnect(userId:Int):Void
	{
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
	
	public function onCommand(command:Dynamic):Void
	{
	}
}