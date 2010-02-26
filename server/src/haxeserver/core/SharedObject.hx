/**
 * ...
 * @author Canab
 */

package haxeserver.core;
import haxelib.common.utils.ArrayUtil;
import haxelib.common.utils.ReflectUtil;
import haxeserver.sharedObjects.SOActionTypes;
import neko.vm.Mutex;

class SharedObject 
{
	public var id(default, null):String;
	public var users(default, null):Array<UserAdapter>;
	public var maxUsers:Int;
	public var isWaiting(default, null):Bool;
	
	private var states:Hash<State>;
	private var mutex:Mutex;
	private var currentUser:UserAdapter;
	
	public function new(remoteId:String) 
	{
		mutex = new Mutex();
		
		id = remoteId;
		users = new Array<UserAdapter>();
		states = new Hash<State>();
		maxUsers = 0;
		isWaiting = true;
		
		log("created");
	}
	
	public function doAction(adapter:UserAdapter, actionData:Array<Dynamic>):Void 
	{
		mutex.acquire();
		currentUser = adapter;
		
		var actionType:String = actionData[0];
		if (actionType == SOActionTypes.CREATE)
			createState(actionData);
			
		for (user in users)
		{
			user.clientAPI.A(this.id, actionData);
		}
		
		currentUser = null;
		mutex.release();
	}
	
	private function createState(actionData:Array<Dynamic>):Void 
	{
		var typeId:Int = actionData[1];
		var stateId:String = actionData[2];
		var stateData:Array<Dynamic> = actionData[3];
		var autoRemove:Bool = actionData[4];
		
		if (!states.exists(stateId))
		{
			var state:State = new State();
			state.ownerId = (autoRemove) ? currentUser.id : -1;
			state.typeId = typeId;
			state.data = stateData;
			state.lockerId = -1;
			states.set(stateId, state);
		}
	}
	
	
	public function addUser(adapter:UserAdapter, needRestoreState:Bool):Bool
	{
		mutex.acquire();
		
		var result:Bool;
		if (ArrayUtil.contains(users, adapter))
		{
			if (needRestoreState)
				restoreState(adapter);
			result = true;
		}
		else if (maxUsers == 0 || users.length < maxUsers)
		{
			users.push(adapter);
			
			if (needRestoreState)
				restoreState(adapter);
				
			if (users.length == maxUsers)
				isWaiting = false;
			
			for (user in users)
			{
				if (user.id != adapter.id)
					user.clientAPI.soUserConnect(this.id, adapter.id);
			}
			log("user connected: " + adapter.id);
			result = true;
		}
		else
		{
			result = false;
		}
		
		mutex.release();
		return result;
	}
	
	private function restoreState(adapter:UserAdapter):Void
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
		adapter.clientAPI.soRestore(this.id, usersList, statesList);
	}

	public function removeUser(adapter:UserAdapter) 
	{
		mutex.acquire();
		
		removeUserStates(adapter);
		users.remove(adapter);
		for (user in users)
		{
			user.clientAPI.soUserDisconnect(this.id, adapter.id);
		}
		log("user disconnected: " + adapter.id);
		
		mutex.release();
	}
	
	private function removeUserStates(adapter:UserAdapter):Void
	{
		var removedStates:Array<String> = [];
		for (stateId in states.keys())
		{
			var state:State = states.get(stateId);
			if (state.ownerId == adapter.id)
				removedStates.push(stateId);
			else if (state.lockerId == adapter.id)
				state.lockerId = -1;
		}
		for (stateId in removedStates)
		{
			removeState(stateId);
		}
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
	
	public function lockState(adapter:UserAdapter, func:String, stateId:String, stateData:Dynamic):Void
	{
		mutex.acquire();
		
		var state:State = states.get(stateId);
		if (state != null && (state.lockerId == -1 || state.lockerId == adapter.id))
		{
			state.lockerId = adapter.id;
			sendState(func, stateId, stateData);
		}
		else
		{
			adapter.clientAPI.soSend(this.id, func, stateId, null);
		}
		
		mutex.release();
	}
	
	public function unLockState(adapter:UserAdapter, func:String, stateId:String, stateData:Dynamic):Void
	{
		mutex.acquire();

		var state:State = states.get(stateId);
		if (state != null && (state.lockerId == -1 || state.lockerId == adapter.id))
		{
			state.lockerId = -1;
			sendState(func, stateId, stateData);
		}
		else
		{
			adapter.clientAPI.soSend(this.id, func, stateId, null);
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
		Application.instance.logger.info("SO:" + id + " " + value);
	}
	
}