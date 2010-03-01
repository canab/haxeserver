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

class SOBaseTest extends AsincTest, implements IRemoteClient
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
		var remoteId:String = "BaseTest" + Main.instance.connection1.userId;
		remote = new RemoteObject(remoteId);
		remote.connect(Main.instance.connection1, this);
	}
	
	/* INTERFACE haxeserver.IRemoteClient */
	
	public function onReady():Void
	{
		remote.createState(playerStateId, player);
	}
	
	public function onStateCreated(stateId:String, state:Dynamic):Void
	{
		var playerData:PlayerData = cast(state, PlayerData);
		assertEquals(player.name, playerData.name);
		assertEquals(player.health, playerData.health);
		assertEquals(player.active, playerData.active);
		assertArrayEquals(player.array, playerData.array);
		
		remote.changeState(playerStateId, { health: player.health - 10 } );
	}
	
	public function onStateChanged(stateId:String, state:Dynamic):Void
	{
		var playerData:PlayerData = cast(state, PlayerData);
		assertEquals(player.name, playerData.name);
		assertEquals(player.health - 10, playerData.health);
		assertEquals(player.active, playerData.active);
		assertArrayEquals(player.array, playerData.array);
		
		remote.removeState(stateId);
	}
	
	public function onStateRemoved(stateId:String, state:Dynamic):Void
	{
		assertEquals(stateId, playerStateId);
		assertEquals(cast(state, PlayerData).name, player.name);
		
		remote.call('rTestCall');
	}
	
	public function rTestCall():Void 
	{
		remote.call("rTestCallWithParams", [1, "string", false, ["array1", "array2"]]);
	}
	
	public function rTestCallWithParams(intValue:Int, stringValue:String, boolValue:Bool,
		arrValue:Array<Dynamic>):Void 
	{
		assertEquals(intValue, 1);
		assertEquals(stringValue, "string");
		assertEquals(boolValue, false);
		assertArrayEquals(arrValue, ["array1", "array2"]);
		
		var command:SampleCommand = new SampleCommand();
		command.text = "commandText";
		remote.sendCommand(command);
	}
	
	public function onCommand(command:Dynamic):Void
	{
		assertEquals(cast(command, SampleCommand).text, "commandText");
		remote.disconnect();
		dispatchComplete();
	}
	
	public function onUserConnect(userId:Int):Void {}
	public function onUserDisconnect(userId:Int):Void {}
	public function onSharedObjectFull():Void {}
}