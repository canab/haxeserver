/**
 * ...
 * @author Canab
 */

package haxeserver.core.so;

import haxelib.common.utils.ArrayUtil;
import haxeserver.core.Application;
import haxeserver.core.UserAdapter;
import haxeserver.so.SOActionTypes;
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
					user.clientAPI.C(this.id, adapter.id);
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
		adapter.clientAPI.R(this.id, usersList, statesList);
	}
	
	public function doAction(adapter:UserAdapter, actionData:Array<Dynamic>):Void 
	{
		mutex.acquire();
		currentUser = adapter;
		
		if (Application.instance.config.verboseLog)
			log(actionData);
		
		// process action
		var actionType:String = actionData[0];
		switch (actionType)
		{
			case SOActionTypes.CREATE:
				createState(actionData[1], actionData[2], actionData[3], actionData[4]);
			case SOActionTypes.CHANGE:
				changeState(actionData[1], actionData[2]);
			case SOActionTypes.REMOVE:
				removeState(actionData[1]);
		}
			
		// call action on each connected user
		for (user in users)
		{
			user.clientAPI.A(this.id, actionData);
		}
		
		currentUser = null;
		mutex.release();
	}
	
	private function createState(typeId:Int, stateId:String, stateData:Dynamic, autoRemove:Bool):Void 
	{
		var state:State = new State();
		state.ownerId = (autoRemove) ? currentUser.id : -1;
		state.typeId = typeId;
		state.data = stateData;
		state.lockerId = -1;
		states.set(stateId, state);
	}
	
	private function changeState(stateId:String, updateData:Array<Dynamic>):Void
	{
		var state:State = states.get(stateId);
		for (i in 0...Std.int(updateData.length / 2))
		{
			var index:Int = updateData[2 * i];
			var value:Dynamic = updateData[2 * i + 1];
			state.data[index] = value;
		}
	}
	
	private function removeState(stateId:String)
	{
		states.remove(stateId);
	}
	
	public function removeUser(adapter:UserAdapter) 
	{
		mutex.acquire();
		
		removeUserStates(adapter);
		users.remove(adapter);
		for (user in users)
		{
			user.clientAPI.D(this.id, adapter.id);
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
	
	public function lockState(adapter:UserAdapter, stateId:String):Bool
	{
		mutex.acquire();
		
		var state:State = states.get(stateId);
		if (state != null && (state.lockerId == -1 || state.lockerId == adapter.id))
			state.lockerId = adapter.id;
		
		mutex.release();
		
		//trace('' + adapter.id + ':L:' + stateId + ' ' + (state.lockerId == adapter.id));
		return (state.lockerId == adapter.id);
	}
	
	public function unlockState(adapter:UserAdapter, stateId:String):Void
	{
		mutex.acquire();

		var state:State = states.get(stateId);
		if (state != null && (state.lockerId == -1 || state.lockerId == adapter.id))
			state.lockerId = -1;
		
		//trace('' + adapter.id + ':U:' + stateId + ' ' + (state.lockerId == -1));
		mutex.release();
	}
	
	public function dispose() 
	{
		log("disposed");
	}
	
	private function log(value:Dynamic) 
	{
		Application.instance.logger.info("(" + id + ") " + value);
	}
	
}