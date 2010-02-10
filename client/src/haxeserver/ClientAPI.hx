/**
 * ...
 * @author canab
 */

package haxeserver;
import haxeserver.interfaces.IClientAPI;

class ClientAPI implements IClientAPI
{
	private var connection:RemoteConnection;
	
	public function new(connection:RemoteConnection)
	{
		this.connection = connection;
	}
	
	private function getRemote(remoteId:String):RemoteObject
	{
		return connection.remoteObjects.get(remoteId);
	}
	
	////////////////////////////////////////////////////////////
	//
	// IClientAPI implementation
	//
	////////////////////////////////////////////////////////////
	
	public function setId(value:Int)
	{
		connection.setUserId(value);
	}
	
	public function soCreate(remoteId:String, stateId:String, stateData:Dynamic, typeId:Int):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyCreateState(typeId, stateId, stateData);
	}
	
	public function soRestore(remoteId:String, usersList:Array<Dynamic>, statesList:Array<Dynamic>):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.restore(usersList, statesList);
	}
	
	public function soUserConnect(remoteId:String, userId:Int):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyUserConnect(userId);
	}
	
	public function soUserDisconnect(remoteId:String, userId:Int):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyUserDisconnect(userId);
	}
	
	public function soSend(remoteId:String, func:String, stateId:String, state:Dynamic):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applySend(func, stateId, state);
	}
	
	public function soCall(remoteId:String, func:String, arguments:Array<Dynamic>):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyCall(func, arguments);
	}
	
	public function soRemove(remoteId:String, stateId:String):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyRemove(stateId);
	}
	
	public function soFull(remoteId:String):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyFull();
	}
	
	public function soCommand(remoteId:String, commandId:Int, parameters:Dynamic):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyCommand(commandId, parameters);
	}
	
}