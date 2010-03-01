/**
 * ...
 * @author Canab
 */

package haxeserver.so;

class RemoteClient implements IRemoteClient
{
	public function new() 
	{
	}
	
	public function onReady():Void
	{
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