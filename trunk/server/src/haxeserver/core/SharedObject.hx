/**
 * ...
 * @author Canab
 */

package haxeserver.core;
import haxelib.utils.ReflectUtil;
import neko.vm.Mutex;

class SharedObject 
{
	public var id(default, null):String;
	public var users(default, null):Array<UserAdapter>;
	public var maxUsers:Int;
	
	private var states:Hash<State>;
	private var mutex:Mutex;
	
	public function new(remoteId:String) 
	{
		mutex = new Mutex();
		
		id = remoteId;
		users = new Array<UserAdapter>();
		states = new Hash<State>();
		maxUsers = 0;
		
		log("created");
	}
	
	public function addUser(target:UserAdapter) 
	{
		mutex.acquire();
		
		users.push(target);
		restoreState(target);
		for (user in users)
		{
			if (user.id != target.id)
				user.clientAPI.soUserConnect(this.id, target.id);
		}
		log("user connected: " + target.id);
		
		mutex.release();
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
		mutex.acquire();
		
		removeUserStates(target);
		users.remove(target);
		for (user in users)
		{
			user.clientAPI.soUserDisconnect(this.id, target.id);
		}
		log("user disconnected: " + target.id);
		
		mutex.release();
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
		mutex.acquire();

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
		
		mutex.release();
	}
	
	public function sendState(func:String, stateId:String, stateData:Dynamic) 
	{
		mutex.acquire();
		
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
		
		mutex.release();
	}
	
	public function lockState(user:UserAdapter, func:String, stateId:String, stateData:Dynamic):Void
	{
		mutex.acquire();
		
		var state:State = states.get(stateId);
		if (state != null && (state.lockerId == -1 || state.lockerId == user.id))
		{
			state.lockerId = user.id;
			sendState(func, stateId, stateData);
		}
		else
		{
			user.clientAPI.soSend(this.id, func, stateId, null);
		}
		
		mutex.release();
	}
	
	public function unLockState(user:UserAdapter, func:String, stateId:String, stateData:Dynamic):Void
	{
		mutex.acquire();

		var state:State = states.get(stateId);
		if (state != null && (state.lockerId == -1 || state.lockerId == user.id))
		{
			state.lockerId = -1;
			sendState(func, stateId, stateData);
		}
		else
		{
			user.clientAPI.soSend(this.id, func, stateId, null);
		}
		
		mutex.release();
	}
	
	public function call(func:String, arguments:Array<Dynamic>):Void 
	{
		mutex.acquire();
		
		for (user in users)
		{
			user.clientAPI.soCall(this.id, func, arguments);
		}
		
		mutex.release();
	}
	
	public function removeState(stateId:String) 
	{
		mutex.acquire();
		
		states.remove(stateId);
		for (user in users)
		{
			user.clientAPI.soRemove(this.id, stateId);
		}

		mutex.release();
	}
	
	public function sendCommand(commandId:Int, parameters:Dynamic) 
	{
		mutex.acquire();
		
		for (user in users)
		{
			user.clientAPI.soCommand(this.id, commandId, parameters);
		}
		log("sendCommand " + commandId);

		mutex.release();
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