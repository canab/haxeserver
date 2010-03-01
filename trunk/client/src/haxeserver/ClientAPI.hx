/**
 * ...
 * @author canab
 */

package haxeserver;

import haxeserver.interfaces.IClientAPI;
import haxeserver.so.RemoteObject;

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
	
	public function C(remoteId:String, userId:Int):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null && remote.ready)
			remote.applyUserConnect(userId);
	}
	
	public function D(remoteId:String, userId:Int):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null && remote.ready)
			remote.applyUserDisconnect(userId);
	}
	
	public function R(remoteId:String, usersList:Array<Dynamic>, statesList:Array<Dynamic>):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null && !remote.ready)
			remote.applyRestore(usersList, statesList);
	}
	
	public function A(remoteId:String, actionData:Array<Dynamic>):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null && remote.ready)
			remote.applyAction(actionData);
	}
}