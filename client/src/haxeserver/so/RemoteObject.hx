/**
 * ...
 * @author Canab
 */

package haxeserver.so;

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
	
	public function new(remoteId:String, maxUsers:Int = 0)
	{
		this.id = remoteId;
		this.maxUsers = maxUsers;
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
		{
			removeConnection();
			client.onReady();
		}
	}
	
	public function applyUserConnect(userId:Int)
	{
		addUser(userId);
	}
	
	private function addUser(userId:Int):Void 
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
			removeConnection();
			ready = false;
		}
	}
	
	private function removeConnection():Void 
	{
		connection.removeRemoteObject(this);
		connected = false;
		connection = null;
	}
	
	public function applyUserDisconnect(userId:Int)
	{
		users.remove(userId);
		client.onUserDisconnect(userId);
	}
	//} endregion
	
	//{ region restore
	public function applyRestore(usersList:Array<Dynamic>, statesList:Array<Dynamic>, maxUsers:Int) 
	{
		for (userId in usersList)
		{
			addUser(userId);
		}
		
		for (state in statesList)
		{
			var stateArray:Array<Dynamic> = cast state;
			var stateId:String = stateArray[0];
			var typeId:Int = stateArray[1];
			var stateData:Dynamic = stateArray[2];
			applyCreateState(typeId, stateId, stateData);
		}
		
		this.maxUsers = maxUsers;
		ready = true;
		client.onReady();
	}
	
	//} endregion
	
	//{ region action
	private function sendAction(actionData:Array<Dynamic>):Void 
	{
		if (!connected)
			throw(this + " not connected.");
		
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
		if (!connected)
			throw(this + " not connected.");
		
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
		if (!connected)
			throw(this + " not connected.");
		
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
	
	
	//{ region lock
	public function lockState(stateId:String, onResult:Bool->Void = null):Void 
	{
		if (!connected)
			throw(this + " not connected.");
		
		connection.serverAPI.L(this.id, stateId, onResult);
	}
	
	public function unlockState(stateId:String):Void 
	{
		if (!connected)
			throw(this + " not connected.");
		
		connection.serverAPI.U(this.id, stateId);
	}
	//} endregion
	
	private function getUserId():Int
	{
		if (!connected)
			throw(this + " not connected.");
		
		return connection.userId;
	}
	
	private function callClient(func:String, args:Array<Dynamic>):Void 
	{
		Reflect.callMethod(client, Reflect.field(client, func), args);
	}
	
	public function getStates(stateClass:Class<Dynamic> = null):Dynamic
	{
		var result:Dynamic = { };
		for (key in states.keys())
		{
			var state:Dynamic = states.get(key);
			if (stateClass == null || Type.getClass(state) == stateClass )
				untyped { result[key] = state; };
		}
		return result;
	}
	
	public function toString():String
	{
		return "RemoteObject(userId="
			+ ((connection != null) ? Std.string(connection.userId) : "null")
			+ ",id=" + id + ")";
	}
}