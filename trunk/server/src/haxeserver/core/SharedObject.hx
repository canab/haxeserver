/**
 * ...
 * @author Canab
 */

package haxeserver.core;
import haxelib.utils.ReflectUtil;

class SharedObject 
{
	public var id(default, null):String;
	public var users(default, null):Array<UserAdapter>;
	
	private var states:Hash<State>;
	
	public function new(remoteId:String) 
	{
		id = remoteId;
		users = new Array<UserAdapter>();
		states = new Hash<State>();
		
		log("created");
	}
	
	public function addUser(target:UserAdapter) 
	{
		users.push(target);
		
		restoreState(target);
		
		for (user in users)
		{
			if (user.id != target.id)
				user.clientAPI.soUserConnect(this.id, target.id);
		}
		log("user connected: " + target.id);
	}
	
	private function restoreState(target:UserAdapter):Void
	{
		var usersList:Array<Dynamic> = [];
		for (user in users)
		{
			usersList.push(user.id);
		}
		
		var statesList:Array<Dynamic> = new Array<Dynamic>();
		
		for (stateId in states.keys())
		{
			var state:State = states.get(stateId);
			var stateData:Array<Dynamic> = new Array<Dynamic>();
			stateData.push(stateId);
			stateData.push(state.typeId);
			stateData.push(state.data);
			statesList.push(stateData);
		}
		target.clientAPI.soRestore(this.id, usersList, statesList);
	}

	public function removeUser(target:UserAdapter) 
	{
		removeUserStates(target);
		users.remove(target);
		for (user in users)
		{
			user.clientAPI.soUserDisconnect(this.id, target.id);
		}
		log("user disconnected: " + target.id);
	}
	
	private function removeUserStates(user:UserAdapter):Void
	{
		var removedStates:Array<String> = [];
		for (stateId in states.keys())
		{
			var state:State = states.get(stateId);
			if (state.ownerId == user.id)
				removedStates.push(stateId);
			else if (state.lockerId == user.id)
				state.lockerId = -1;
		}
		for (stateId in removedStates)
			removeState(stateId);
	}
	
	public function createState(ownerId:Int, typeId:Int, stateId:String, stateData:Dynamic):Void 
	{
		if (!states.exists(stateId))
		{
			var state:State = new State();
			state.ownerId = ownerId;
			state.typeId = typeId;
			state.data = stateData;
			state.lockerId = -1;
			states.set(stateId, state);
		}
		for (user in users)
		{
			user.clientAPI.soCreate(this.id, stateId, stateData, typeId);
		}
	}
	
	public function sendState(func:String, stateId:String, stateData:Dynamic) 
	{
		var state:State = states.get(stateId);
		if (state != null)
		{
			ReflectUtil.copyFields(stateData, state.data);
			for (user in users)
			{
				user.clientAPI.soSend(this.id, func, stateId, stateData);
			}
		}
		else
		{
			throw "Send state to null object: " + stateId;
		}
	}
	
	public function lockState(user:UserAdapter, func:String, stateId:String, stateData:Dynamic):Void
	{
		var state:State = states.get(stateId);
		if (state.lockerId == -1 || state.lockerId == user.id)
		{
			state.lockerId = user.id;
			sendState(func, stateId, stateData);
		}
		else
		{
			user.clientAPI.soSend(this.id, func, stateId, null);
		}
	}
	
	public function unLockState(user:UserAdapter, func:String, stateId:String, stateData:Dynamic):Void
	{
		var state:State = states.get(stateId);
		if (state.lockerId == -1 || state.lockerId == user.id)
		{
			state.lockerId = -1;
			sendState(func, stateId, stateData);
		}
		else
		{
			user.clientAPI.soSend(this.id, func, stateId, null);
		}
	}
	
	public function call(func:String, arguments:Array<Dynamic>):Void 
	{
		for (user in users)
		{
			user.clientAPI.soCall(this.id, func, arguments);
		}
	}
	
	public function removeState(stateId:String) 
	{
		states.remove(stateId);
		for (user in users)
		{
			user.clientAPI.soRemove(this.id, stateId);
		}
	}
	
	public function sendCommand(commandId:Int, parameters:Dynamic) 
	{
		for (user in users)
		{
			user.clientAPI.soCommand(this.id, commandId, parameters);
		}
		log("sendCommand " + commandId);
	}
	
	public function dispose() 
	{
		log("disposed");
	}
	
	private function log(value:Dynamic) 
	{
		Application.instance.logger.trace("SO:" + id + " " + value);
	}
	
}