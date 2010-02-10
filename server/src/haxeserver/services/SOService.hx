/**
 * ...
 * @author canab
 */

package haxeserver.services;
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
	
	public function connectToFreeSO(soPrefix:String, maxUsers:Int):String
	{
		soMutex.acquire();
		
		var remoteId:String = null;
		for (so in application.sharedObjects)
		{
			if (so.id.indexOf(soPrefix) == 0)
			{
				if (application.addUserToSO(currentUser, so.id, maxUsers, false))
				{
					remoteId = so.id;
					break;
				}
			}
		}
		
		if (remoteId == null)
		{
			remoteId = getNextRemoteId(soPrefix);
			application.addUserToSO(currentUser, remoteId, maxUsers, false);
		}
		
		soMutex.release();
		return remoteId;
	}
	
	private function getNextRemoteId(soPrefix:String):String
	{
		if (soIds.get(soPrefix) == null)
			soIds.set(soPrefix, 0);
		
		var nextNum:Int = soIds.get(soPrefix) + 1;
		var remoteId:String = soPrefix + Std.string(nextNum);
		while (application.hasSharedObject(remoteId))
		{
			nextNum++;
			remoteId = soPrefix + Std.string(nextNum);
		}
		soIds.set(soPrefix, nextNum);
		return remoteId;
	}
	
	public function getSharedObjects(namePrefix:String):Array<Dynamic>
	{
		var result:Array<Dynamic> = [];
		for (so in application.sharedObjects)
		{
			if (namePrefix == null || so.id.indexOf(namePrefix) == 0)
				result.push(so.id);
		}
		return result;
	}
	
}