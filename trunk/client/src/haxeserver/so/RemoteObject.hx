/**
 * ...
 * @author Canab
 */

package haxeserver.so;

import haxelib.common.utils.ReflectUtil;
import haxeserver.RemoteConnection;


class RemoteObject 
{
	public var id(default, null):String;
	public var states(default, null):Hash<Dynamic>;
	public var users(default, null):Array<Int>;
	public var client(default, null):IRemoteClient;
	public var maxUsers:Int;
	
	public var userId(getUserId, null):Int;
	
	public var connected(default, null):Bool;
	public var ready(default, null):Bool;
	
	private var connection:RemoteConnection;
	
	public function new(remoteId:String)
	{
		id = remoteId;
		maxUsers = 0;
		ready = false;
		connected = false;
		
		states = new Hash<Dynamic>();
		users = new Array<Int>();
	}
	
	//{ region connect
	public function connect(connection:RemoteConnection, client:IRemoteClient) 
	{
		if (connected)
		{
			throw toString() + " is already connected.";
		}
		else
		{
			this.connection = connection;
			this.client = client;
			connection.addRemoteObject(this);
			connection.serverAPI.C(id, maxUsers, onConnect);
			connected = true;
		}
	}
	
	private function onConnect(result:Bool):Void
	{
		if (!result)
			client.onSharedObjectFull();
	}
	
	public function applyUserConnect(userId:Int)
	{
		users.push(userId);
		client.onUserConnect(userId);
	}
	//} endregion
	
	//{ region disconnect
	public function disconnect() 
	{
		if (!connected)
		{
			throw toString() + " is not connected.";
		}
		else
		{
			connection.serverAPI.D(this.id);
			connection.removeRemoteObject(this);
			connected = false;
			connection = null;
			ready = false;
		}
	}
	
	public function applyUserDisconnect(userId:Int)
	{
		users.remove(userId);
		client.onUserDisconnect(userId);
	}
	//} endregion
	
	//{ region restore
	public function applyRestore(usersList:Array<Dynamic>, statesList:Array<Dynamic>) 
	{
		for (userId in usersList)
		{
			applyUserConnect(userId);
		}
		
		for (state in statesList)
		{
			var stateArray:Array<Dynamic> = cast state;
			var stateId:String = stateArray[0];
			var typeId:Int = stateArray[1];
			var stateData:Dynamic = stateArray[2];
			applyCreateState(typeId, stateId, stateData);
		}
		
		ready = true;
		client.onReady();
	}
	
	public function applyFull():Void 
	{
		connection.remoteObjects.remove(this.id);
		client.onSharedObjectFull();
	}
	//} endregion
	
	//{ region action
	private function sendAction(actionData:Array<Dynamic>):Void 
	{
		connection.serverAPI.A(this.id, actionData);
	}
	
	public function applyAction(actionData:Array<Dynamic>):Void 
	{
		var actionType:String = actionData[0];
		switch (actionType)
		{
			case SOActionTypes.CREATE:
				applyCreateState(actionData[1], actionData[2], actionData[3]);
			case SOActionTypes.CHANGE:
				applyChangeState(actionData[1], actionData[2]);
			case SOActionTypes.REMOVE:
				applyRemoveState(actionData[1]);
			case SOActionTypes.CALL:
				applyCall(actionData[1], actionData[2]);
			case SOActionTypes.COMMAND:
				applyCommand(actionData[1], actionData[2]);
		}
	}
	//} endregion
	
	//{ region createState
	public function createState(stateId:String, state:Dynamic, autoRemove:Bool = false):Void 
	{
		var typeId:Int = connection.getClassId(Type.getClass(state));
		if (typeId == -1)
		{
			throw "Class " + Type.getClassName(Type.getClass(state)) +
				" is not registered by RemoteConnection.registerClass().";
		}
		else
		{
			sendAction([SOActionTypes.CREATE, typeId, stateId, SOUtil.getObjectData(state), autoRemove]);
		}
	}
	
	private function applyCreateState(typeId:Int, stateId:String, stateData:Array<Dynamic>):Void 
	{
		/*trace('-------------------');
		trace(connected);
		trace(ready);
		trace(connection);*/
		
		var state = connection.getTypedObject(typeId);
		SOUtil.restoreObject(state, stateData);
		states.set(stateId, state);
		client.onStateCreated(stateId, state);
	}
	//} endregion

	//{ region changeState
	public function changeState(stateId:String, changeData:Dynamic):Void 
	{
		var state:Dynamic = states.get(stateId);
		if (state == null)
		{
			throw "Cannot change state (id=" + stateId + ") if it is not exists.";
		}
		else
		{
			sendAction([
				SOActionTypes.CHANGE, stateId, SOUtil.getUpdateData(state, changeData)
			]);
		}
	}
	
	private function applyChangeState(stateId:String, updateData:Dynamic):Void
	{
		var state:Dynamic = states.get(stateId);
		SOUtil.updateObject(state, updateData);
		client.onStateChanged(stateId, state);
	}	
	//} endregion
	
	//{ region removeState
	public function removeState(stateId:String):Void
	{
		sendAction([SOActionTypes.REMOVE, stateId]);
	}
	
	private function applyRemoveState(stateId:String):Void
	{
		var state:Dynamic = states.get(stateId);
		states.remove(stateId);
		client.onStateRemoved(stateId, state);
	}
	//} endregion
	
	//{ region call
	public function call(func:String, args:Array<Dynamic> = null):Void 
	{
		sendAction([SOActionTypes.CALL, func, args]);
	}
	
	public function applyCall(func:String, args:Array<Dynamic>):Void 
	{
		callClient(func, args);
	}
	//} endregion
	
	//{ region command
	public function sendCommand(command:Dynamic):Void
	{
		var typeId:Int = connection.getClassId(Type.getClass(command));
		if (typeId == -1)
		{
			throw "Class" + Type.getClassName(Type.getClass(command)) +
				" is not registered by RemoteConnection.registerClass().";
		}
		else
		{
			sendAction([SOActionTypes.COMMAND, typeId, SOUtil.getObjectData(command)]);
		}
	}
	
	private function applyCommand(typeId:Int, data:Array<Dynamic>):Void
	{
		var command:Dynamic = connection.getTypedObject(typeId);
		SOUtil.restoreObject(command, data);
		client.onCommand(command);
	}
	//} endregion
	
	
	
	/*
	
	
	public function lockState(func:String, stateId:String, state:Dynamic = null):Void 
	{
		var stateData:Dynamic = {};
		if (state)
			ReflectUtil.copyFields(state, stateData);
		connection.serverAPI.soLock(this.id, func, stateId, stateData);
	}
	
	public function unLockState(func:String, stateId:String, state:Dynamic = null):Void 
	{
		var stateData:Dynamic = {};
		if (state)
			ReflectUtil.copyFields(state, stateData);
		connection.serverAPI.soUnLock(this.id, func, stateId, stateData);
	}
	
	*/
	
	private function getUserId():Int
	{
		return connection.userId;
	}
	
	private function callClient(func:String, args:Array<Dynamic>):Void 
	{
		Reflect.callMethod(client, Reflect.field(client, func), args);
	}
	
	public function toString():String
	{
		return "RemoteObject(userId="
			+ ((connection != null) ? Std.string(connection.userId) : "null")
			+ ",id=" + id + ")";
	}
}