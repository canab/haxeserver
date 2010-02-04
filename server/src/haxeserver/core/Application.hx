/**
 * ...
 * @author Canab
 */
package haxeserver.core;
import haxe.remoting.Context;
import haxe.remoting.SocketConnection;
 
class Application 
{
	static public var instance(default, null):Application;
	
	static public function createInstance():Void
	{
		if (instance == null)
		{
			instance = new Application();
		}
	}
	
	public var logger(default, null):Logger;
	public var users(default, null):IntHash<UserAdapter>;
	public var sharedObjects(default, null):Hash<SharedObject>;
	
	private var idCounter:Int;
	
	public function new() 
	{
		logger = new Logger();
		users = new IntHash<UserAdapter>();
		sharedObjects = new Hash<SharedObject>();
		idCounter = 0;
	}
	
	public function addConnection(connection:SocketConnection, context:Context)
	{
		var userId:Int = idCounter++;
		logger.trace("user connected: id=" + userId);
		
		var adapter:UserAdapter = new UserAdapter(connection, userId);
		context.addObject("S", adapter);
		users.set(userId, adapter);
		(cast connection).__user = adapter;
	}
	
	public function removeConnection(cannection:SocketConnection) 
	{
		var user:UserAdapter = (cast cannection).__user;
		for (so in user.sharedObjects)
		{
			removeUserFromSO(user, so.id);
		}
		logger.trace("user disconnected: id=" + user.id);
		users.remove(user.id);
	}
	
	public function getSharedObject(remoteId:String, maxUsers:Int):SharedObject
	{
		var so:SharedObject = sharedObjects.get(remoteId);
		if (so == null)
		{
			so = new SharedObject(remoteId);
			so.maxUsers = maxUsers;
			sharedObjects.set(remoteId, so);
		}
		return so;
	}
	
	public function addUserToSO(user:UserAdapter, remoteId:String, maxUsers:Int) 
	{
		var so:SharedObject = getSharedObject(remoteId, maxUsers);
		if (so.users.length == 0 || so.users.length < so.maxUsers)
		{
			user.sharedObjects.set(so.id, so);
			so.addUser(user);
		}
		else
		{
			user.clientAPI.soFull(so.id);
		}
	}
	
	public function removeUserFromSO(user:UserAdapter, remoteId:String) 
	{
		var so:SharedObject = sharedObjects.get(remoteId);
		user.sharedObjects.remove(so.id);
		so.removeUser(user);
		if (so.users.length == 0)
		{
			so.dispose();
			sharedObjects.remove(so.id);
		}
	}
	
}