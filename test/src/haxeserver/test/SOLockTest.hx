/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;
import haxeserver.test.data.ItemData;
import haxeserver.test.data.PlayerData;

private class TestClient extends RemoteClient
{
	public function new():Void 
	{
		super();
	}
	
	dynamic public function readyHandler():Void {}
	dynamic public function userDisconnectHandler(userId:Int):Void {}
	dynamic public function onUnlocked():Void { }
	
	override public function onReady():Void 
	{
		readyHandler();
	}
	
	override public function onUserDisconnect(userId:Int):Void 
	{
		userDisconnectHandler(userId);
	}
}

class SOLockTest extends AsincTest
{
	private var myRemote:RemoteObject;
	private var myClient:TestClient;
	
	private var otherRemote:RemoteObject;
	private var otherClient:TestClient;

	public function new()
	{
		super();
	}
	
	override public function initialize():Void 
	{
		var remoteId:String = "LockTest" + Main.instance.connection1.userId + "_" + tryNum;
		
		myClient = new TestClient();
		myClient.readyHandler = onMyClientReady;
		myRemote = new RemoteObject(remoteId);
		myRemote.connect(Main.instance.connection1, myClient);
		
		otherClient = new TestClient();
		otherClient.readyHandler = onOtherClientReady;
		otherRemote = new RemoteObject(remoteId);
	}
	
	private function onMyClientReady():Void
	{
		myRemote.createState('p', new PlayerData());
		myRemote.createState('i', new ItemData());
		myRemote.lockState('p');
		myRemote.lockState('i', onStatesLocked);
	}
	
	private function onStatesLocked(result:Bool):Void
	{
		assertEquals(result, true);
		otherRemote.connect(Main.instance.connection2, otherClient);
	}
	
	private function onOtherClientReady():Void
	{
		otherRemote.unlockState('p');
		otherRemote.lockState('p', onTryLockedState);
	}
	
	private function onTryLockedState(result:Bool):Void
	{
		assertEquals(result, false);
		myRemote.unlockState('p');
		myClient.onUnlocked = onUnlocked;
		myRemote.call('onUnlocked');
	}
	
	public function onUnlocked():Void 
	{
		otherRemote.lockState('p', onTryUnlockedState);
	}
	
	private function onTryUnlockedState(result:Bool):Void
	{
		assertEquals(result, true);
		otherClient.userDisconnectHandler = onUserDisconnect;
		myRemote.disconnect();
	}
	
	private function onUserDisconnect(userId:Int):Void
	{
		otherRemote.lockState('i', onItemLock);
	}
	
	private function onItemLock(result:Bool):Void
	{
		assertEquals(result, true);
		otherRemote.disconnect();
		dispatchComplete();
	}
	
	
}