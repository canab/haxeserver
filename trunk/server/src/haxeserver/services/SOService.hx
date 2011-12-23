/**
 * ...
 * @author canab
 */

package haxeserver.services;

import haxeserver.core.so.SharedObject;
import neko.vm.Mutex;

class SOService extends ServiceBase
{
	static private var soMutex:Mutex;
	static private var soIds:Hash<Int>;
	
	public function new() 
	{
		super();
		if (soMutex == null)
		{
			soMutex = new Mutex();
			soIds = new Hash<Int>();
		}
	}
	
	public function createSharedObject(soPrefix:String, maxUsers:Int = 0, name:String = null):String
	{
		soMutex.acquire();
		
		var remoteId:String = getNextRemoteId(soPrefix);
		application.addUserToSO(currentUser, remoteId, maxUsers, name, false);
		
		soMutex.release();
		
		return remoteId;
	}
	
	public function connectToFreeSO(soPrefix:String, maxUsers:Int):String
	{
		soMutex.acquire();
		
		var remoteId:String = null;
		var waitingObjects:Array<SharedObject> = getWaitingObjects(soPrefix, maxUsers);
		for (so in waitingObjects)
		{
			if (application.addUserToSO(currentUser, so.id, maxUsers, null, false))
			{
				remoteId = so.id;
				break;
			}
		}
		
		if (remoteId == null)
		{
			remoteId = getNextRemoteId(soPrefix);
			application.addUserToSO(currentUser, remoteId, maxUsers, null, false);
		}
		
		soMutex.release();
		return remoteId;
	}
	
	private function getWaitingObjects(prefix:String, maxUsers:Int):Array<SharedObject>
	{
		var result:Array<SharedObject> = [];
		for (so in application.sharedObjects)
		{
			if (so.isWaiting && so.maxUsers == maxUsers && so.id.indexOf(prefix) == 0)
				result.push(so);
		}
		return result;
	}
	
	private function getNextRemoteId(prefix:String):String
	{
		if (soIds.get(prefix) == null)
			soIds.set(prefix, 0);
		
		var nextNum:Int = soIds.get(prefix) + 1;
		var remoteId:String = prefix + '|' + Std.string(nextNum);
		while (application.hasSharedObject(remoteId))
		{
			nextNum++;
			remoteId = prefix + Std.string(nextNum);
		}
		soIds.set(prefix, nextNum);
		return remoteId;
	}
	
	public function getSharedObjects(namePrefix:String, haveFreeSlots:Bool):Array<Dynamic>
	{
		var result:Array<Dynamic> = [];
		
		for (so in application.sharedObjects)
		{
			if (namePrefix != null && so.id.indexOf(namePrefix) != 0)
				continue;
				
			if (haveFreeSlots)
			{
				if (so.users.length == so.maxUsers || !so.isConnectable)
					continue;
			}
				
			result.push([so.id, so.maxUsers, so.users.length, so.name]);
		}
		return result;
	}
	
	public function setUnconnectable(soId:String):Void 
	{
		application.sharedObjects.get(soId).isConnectable = false;
	}
	
}