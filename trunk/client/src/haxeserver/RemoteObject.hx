/**
 * ...
 * @author Canab
 */

package haxeserver;
import flash.Error;
import haxelib.common.commands.ICommand;
import haxelib.common.utils.ReflectUtil;
import haxeserver.sharedObjects.SOActionTypes;
import haxeserver.sharedObjects.SOUtil;

class RemoteObject 
{
	public var id(default, null):String;
	public var states(default, null):Hash<Dynamic>;
	public var users(default, null):Array<Int>;
	public var client(default, null):IRemoteClient;
	public var maxUsers:Int;
	
	public var userId(getUserId, null):Int;
	private function getUserId():Int
	{
		return connection.userId;
	}
	
	public var connected(default, null):Bool;
	public var ready(default, null):Bool;
	
	private var connection:RemoteConnection;
	
	public function new(remoteConnection:RemoteConnection, remoteId:String)
	{
		connection = remoteConnection;
		id = remoteId;
		maxUsers = 0;
		ready = false;
		connected = false;
		
		states = new Hash<Dynamic>();
		users = new Array<Int>();
	}
	
	public function connect(client:IRemoteClient) 
	{
		if (connected)
		{
			throw "RemoteObject (id=" + id + ") is already connected";
		}
		else
		{
			this.client = client;
			connection.serverAPI.C(id, maxUsers);
			connected = true;
		}
	}
	
	public function disconnect() 
	{
		connection.disconnectRemoteObject(id);
	}
	
	public function restore(usersList:Array<Dynamic>, statesList:Array<Dynamic>) 
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
			//applyCreateState(typeId, stateId, stateData);
		}
		
		ready = true;
		client.onReady();
	}
	
	public function applyFull():Void 
	{
		try
		{
			connection.remoteObjects.remove(this.id);
			client.onSharedObjectFull();
		}
		catch (e:Error)
		{
			trace(e.message);
			trace(e.getStackTrace());
		}
	}
	
	
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
			sendAction([
				SOActionTypes.CREATE, typeId, stateId, SOUtil.getObjectData(state), autoRemove
			]);
		}
	}
	
	private function sendAction(actionData:Array<Dynamic>):Void 
	{
		connection.serverAPI.A(this.id, actionData);
	}
	
	public function applyAction(actionData:Array<Dynamic>):Void 
	{
		var actionType:String = actionData[0];
		if (actionType == SOActionTypes.CREATE)
			applyCreateState(actionData);
	}
	
	private function applyCreateState(actionData:Array<Dynamic>):Void 
	{
		var typeId:Int = actionData[1];
		var stateId:String = actionData[2];
		var stateData:Array<Dynamic> = actionData[3];
		var autoRemove:Bool = actionData[4];
		
		try
		{
			var state = connection.getTypedObject(typeId);
			SOUtil.restoreObject(state, stateData);
			states.set(stateId, state);
			client.onStateCreated(stateId, state);
		}
		catch (e:Error)
		{
			trace(e.message);
			trace(e.getStackTrace());
		}
	}
	
	/*public function removeState(stateId:String)
	{
		connection.serverAPI.soRemove(id, stateId);
	}
	
	public function call(func:String, arguments:Array<Dynamic> = null):Void 
	{
		connection.serverAPI.soCall(this.id, func, arguments);
	}
	
	public function sendState(func:String, stateId:String, state:Dynamic):Void 
	{
		var stateData:Dynamic = {};
		ReflectUtil.copyFields(state, stateData);
		connection.serverAPI.soSend(this.id, func, stateId, stateData);
	}
	
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
	
	public function sendCommand(command:Dynamic)
	{
		var commandId:Int = connection.getClassId(Type.getClass(command));
		if (commandId == -1)
		{
			throw Type.getClassName(Type.getClass(command)) +
				" has not been registered by RemoteConnection.registerClass().";
		}
		else
		{
			var parameters:Dynamic = { };
			ReflectUtil.copyFields(command, parameters);
			connection.serverAPI.soCommand(id, commandId, parameters);
			//trace(parameters);
		}
	}
	
	*/
	
	public function applyUserConnect(userId:Int)
	{
		try
		{
			users.push(userId);
			client.onUserConnect(userId);
		}
		catch (e:Error)
		{
			trace(e.message);
			trace(e.getStackTrace());
		}
	}
	
	public function applyUserDisconnect(userId:Int)
	{
		try
		{
			users.remove(userId);
			client.onUserDisconnect(userId);
		}
		catch (e:Error)
		{
			trace(e.message);
			trace(e.getStackTrace());
		}
	}
	
	public function applyRemove(stateId:String)
	{
		try
		{
			var state:Dynamic = states.get(stateId);
			states.remove(stateId);
			client.onStateRemoved(stateId, state);
		}
		catch (e:Error)
		{
			trace(e.message);
			trace(e.getStackTrace());
		}
	}
	
	public function applySend(func:String, stateId:String, stateData:Dynamic):Void
	{
		try
		{
			var state:Dynamic = states.get(stateId);
			if (stateData != null)
			{
				ReflectUtil.copyFields(stateData, state);
				client.onStateChanged(stateId, state);
			}
			else
			{
				state = null;
			}
			if (func != null)
				callClient(func, [stateId, state]);
		}
		catch (e:Error)
		{
			trace(e.message);
			trace(e.getStackTrace());
		}
	}
	
	public function applyCall(func:String, arguments:Array<Dynamic>):Void 
	{
		try
		{
			callClient(func, arguments);
		}
		catch (e:Error)
		{
			trace(e.message);
			trace(e.getStackTrace());
		}
	}
	
	public function applyCommand(commandId:Int, parameters:Dynamic)
	{
		try
		{
			var command:Dynamic = connection.getTypedObject(commandId);
			client.onCommand(command);
		}
		catch (e:Error)
		{
			trace(e.message);
			trace(e.getStackTrace());
		}
	}
	
	private function callClient(func:String, arguments:Array<Dynamic>):Void 
	{
		try
		{
			Reflect.callMethod(client, Reflect.field(client, func), arguments);
		}
		catch (error:Error)
		{
			trace('clientCall Error ' + error.message);
			trace(error.getStackTrace());
		}
	}
}