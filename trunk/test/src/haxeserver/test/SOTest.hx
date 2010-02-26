/**
 * ...
 * @author canab
 */

package haxeserver.test;

import haxelib.test.AsincTest;
import haxeserver.so.IRemoteClient;
import haxeserver.so.RemoteObject;
import haxeserver.test.data.PlayerData;
import haxeserver.test.data.SampleCommand;

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
		
		remote.changeState(playerStateId, { health: player.health - 10 } );
	}
	
	public function onStateChanged(stateId:String, state:Dynamic):Void
	{
		var playerData:PlayerData = cast(state, PlayerData);
		assertTrue(player.name == playerData.name);
		assertTrue(player.health - 10 == playerData.health);
		assertTrue(player.active == playerData.active);
		assertEquals(player.array, playerData.array);
		
		remote.removeState(stateId);
	}
	
	public function onStateRemoved(stateId:String, state:Dynamic):Void
	{
		assertTrue(stateId == playerStateId);
		assertTrue(cast(state, PlayerData).name == player.name);
		
		remote.call('rTestCall');
	}
	
	public function rTestCall():Void 
	{
		remote.call("rTestCallWithParams", [1, "string", false, ["array1", "array2"]]);
	}
	
	public function rTestCallWithParams(intValue:Int, stringValue:String, boolValue:Bool,
		arrValue:Array<Dynamic>):Void 
	{
		assertTrue(intValue == 1);
		assertTrue(stringValue == "string");
		assertTrue(boolValue == false);
		assertEquals(arrValue, ["array1", "array2"]);
		
		var command:SampleCommand = new SampleCommand();
		command.text = "commandText";
		remote.sendCommand(command);
	}
	
	public function onCommand(command:Dynamic):Void
	{
		assertTrue(cast(command, SampleCommand).text == "commandText");
		dispatchComplete();
	}
	
	public function onUserConnect(userId:Int):Void {}
	public function onUserDisconnect(userId:Int):Void {}
	public function onSharedObjectFull():Void {}
}