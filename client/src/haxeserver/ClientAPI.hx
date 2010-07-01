/**
 * ...
 * @author canab
 */

package haxeserver;

import haxeserver.interfaces.IClientAPI;
import haxeserver.so.RemoteObject;

class CallEntry
{
	public var func:Dynamic;
	public var args:Array<Dynamic>;
	
	public function new(func:Dynamic, args:Array<Dynamic>)
	{
		this.func = func;
		this.args = args;
	}
}

class ClientAPI implements IClientAPI
{
	private var connection:RemoteConnection;
	private var callQueue:Array<CallEntry>;
	
	public function new(connection:RemoteConnection)
	{
		this.connection = connection;
		this.callQueue = new Array<CallEntry>();
	}
	
	private function getRemote(remoteId:String):RemoteObject
	{
		return connection.remoteObjects.get(remoteId);
	}
	
	private function addCall(func:Dynamic, args:Array<Dynamic>):Void
	{
		callQueue.push(new CallEntry(func, args));
	}
	
	public function processCallQueue():Void 
	{
		while (callQueue.length > 0)
		{
			var entry:CallEntry = callQueue.shift();
			Reflect.callMethod(this, entry.func, entry.args);
		}
	}
	
	////////////////////////////////////////////////////////////
	//
	// IClientAPI implementation
	//
	////////////////////////////////////////////////////////////
	
	public function I(value:Int)
	{
		addCall(doI, [value]);
	}
	private function doI(value:Int)
	{
		connection.setUserId(value);
	}
	
	public function C(remoteId:String, userId:Int):Void
	{
		addCall(doC, [remoteId, userId]);
	}
	private function doC(remoteId:String, userId:Int):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null && remote.ready)
			remote.applyUserConnect(userId);
	}
	
	
	public function D(remoteId:String, userId:Int):Void
	{
		addCall(doD, [remoteId, userId]);
	}
	private function doD(remoteId:String, userId:Int):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null && remote.ready)
			remote.applyUserDisconnect(userId);
	}
	
	public function R(remoteId:String, usersList:Array<Dynamic>,
		statesList:Array<Dynamic>, maxUsers:Int, name:String):Void
	{
		addCall(doR, [remoteId, usersList, statesList, maxUsers, name]);
	}
	private function doR(remoteId:String, usersList:Array<Dynamic>,
		statesList:Array<Dynamic>, maxUsers:Int, name:String):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null && !remote.ready)
			remote.applyRestore(usersList, statesList, maxUsers, name);
	}
	
	
	public function A(remoteId:String, actionData:Array<Dynamic>):Void
	{
		addCall(doA, [remoteId, actionData]);
	}
	private function doA(remoteId:String, actionData:Array<Dynamic>):Void
	{
		var remote:RemoteObject = getRemote(remoteId);
		if (remote != null && remote.ready)
			remote.applyAction(actionData);
	}
}