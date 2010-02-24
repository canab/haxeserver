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
	private var remote1:RemoteObject;
	private var remote2:RemoteObject;

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void
	{
		remote1 = Main.instance.connection1.getRemoteObject(Main.instance.remoteId);
		remote1.connect(this);
		remote2 = Main.instance.connection2.getRemoteObject(Main.instance.remoteId);
		remote2.connect(new RemoteClient());
	}
	
	override public function dispose():Void
	{
	}
	
	// IRemoteClient implementation
	
	public function onReady():Void
	{
		trace('onReady');
	}
	
	public function onUserConnect(userId:Int):Void
	{
		trace('onUserConnect ' + userId);
		if (remote1.users.length == 2)
		{
			remote2.createState('playerData', new PlayerData());
		}
	}
	
	public function onUserDisconnect(userId:Int):Void
	{
		trace('onUserDisconnect ' + userId);
		remote1.disconnect();
		dispatchComplete();
	}
	
	public function onStateCreated(stateId:String, state:Dynamic):Void
	{
		trace('onStateCreated ' + stateId);
		trace(state);
		remote2.sendState(null, 'playerData', { health: 90 } );
	}
	
	public function onStateChanged(stateId:String, state:Dynamic):Void
	{
		trace('onStateChanged ' + stateId);
		trace(state);
		remote2.removeState('playerData');
	}
	
	public function onStateRemoved(stateId:String, state:Dynamic):Void
	{
		trace('onStateRemoved ' + stateId);
		trace(state);
		remote2.disconnect();
	}
	
	public function onSharedObjectFull():Void
	{
		trace('onSharedObjectFull ');
	}
	
	public function onCommand(command:Dynamic):Void
	{
		trace('onCommand');
		trace('command');
	}
	
}