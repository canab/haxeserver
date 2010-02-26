﻿/**
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
	
	public function A(remoteId:String, actionData:Array<Dynamic>):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyAction(actionData);
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
	
	public function soCall(remoteId:String, func:String, arguments:Array<Dynamic>):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null)
			remote.applyCall(func, arguments);
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