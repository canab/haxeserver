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
	private var remotePrefix:String;
	private var maxUsers:Int;
	private var name:String;
	private var remote:RemoteObject;
	private var remoteId:String;

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void 
	{
		remotePrefix = "SOCreateTest" + Main.instance.connection1.userId + "_" + tryNum;
		maxUsers = 2;
		name = "QWEQWE";
		
		var service:SOService = new SOService(onCreate);
		service.connection = Main.instance.connection1;
		service.createSharedObject(remotePrefix, maxUsers, name);
	}
	
	private function onCreate(result:String):Void
	{
		remoteId = result;
		var service:SOService = new SOService(onGet);
		service.connection = Main.instance.connection1;
		service.getSharedObjects(remotePrefix, true);
	}
	
	private function onGet(result:Array<Dynamic>):Void
	{
		var soInfo:Array<Dynamic> = result[0];
		assertEquals(soInfo[0], remoteId);
		assertEquals(soInfo[1], maxUsers);
		assertEquals(soInfo[2], 1);
		assertEquals(soInfo[3], name);
		
		dispatchComplete();
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