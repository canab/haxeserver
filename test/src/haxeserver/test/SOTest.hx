/**
 * ...
 * @author canab
 */

package haxeserver.test;

import haxelib.test.AsincTest;
import haxeserver.IRemoteClient;
import haxeserver.RemoteClient;
import haxeserver.RemoteObject;
import haxeserver.test.data.PlayerData;

class SOTest extends AsincTest, implements IRemoteClient
{
	static private var playerStateId:String = 'P';
	static private var player:PlayerData = new PlayerData();
	
	private var remote:RemoteObject;
	
	public function new() 
	{
		super();
	}
	
	override public function initialize():Void
	{
		remote = Main.instance.connection1.getRemoteObject(Main.instance.remoteId);
		remote.connect(this);
	}
	
	/* INTERFACE haxeserver.IRemoteClient */
	
	public function onReady():Void
	{
		remote.createState(playerStateId, player);
	}
	
	public function onStateCreated(stateId:String, state:Dynamic):Void
	{
		var playerData:PlayerData = cast(state, PlayerData);
		assertTrue(player.name == playerData.name);
		assertTrue(player.health == playerData.health);
		assertTrue(player.active == playerData.active);
		assertEquals(player.array, playerData.array);
		
		trace(stateId);
		trace(state);
		
		dispatchComplete();
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
	
	public function onUserConnect(userId:Int):Void {}
	public function onUserDisconnect(userId:Int):Void {}
	public function onSharedObjectFull():Void {}
}