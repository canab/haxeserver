/**
 * ...
 * @author Canab
 */
package haxeserver.core;
import haxe.remoting.Context;
import haxe.remoting.SocketConnection;
import neko.net.ThreadRemotingServer;
 
class Application 
{
	static public var instance(default, null):Application;
	
	static public function createInstance():Void
	{
		if (instance == null)
		{
			instance = new Application();
			instance.initialize();
			instance.createServer();
		}
	}
	
	public var logger(default, null):Logger;
	public var users(default, null):IntHash<UserAdapter>;
	public var sharedObjects(default, null):Hash<SharedObject>;
	public var config(default, null):ApplicationConfig;
	
	private var idCounter:Int;
	private var server:ThreadRemotingServer;
	
	public function new()
	{
		idCounter = 0;
		logger = new Logger("log/server.log", 1024 * 1024);
		
		users = new IntHash<UserAdapter>();
		sharedObjects = new Hash<SharedObject>();
	}
	
	public function initialize():Void
	{
		config = new ApplicationConfig("server-config.xml");
	}
	
	public function createServer():Void
	{
		server = new ThreadRemotingServer();
		server.initClientApi = initClientAPI;
		server.clientDisconnected = clientDisconnected;
		logger.info("Starting NekoServer at " + config.host + ':' + config.port);
		server.run(config.host, config.port);
	}
	
	private function initClientAPI(connection:SocketConnection, context:Context)
	{
		var userId:Int = idCounter++;
		logger.info("user connected, id=" + userId);
		
		var adapter:UserAdapter = new UserAdapter(connection, userId);
		context.addObject("S", adapter);
		users.set(userId, adapter);
		(cast connection).__user = adapter;
	}
	
	private function clientDisconnected(cannection:SocketConnection) 
	{
		var user:UserAdapter = (cast cannection).__user;
		for (so in user.sharedObjects)
		{
			removeUserFromSO(user, so.id);
		}
		logger.info("user disconnected, id=" + user.id);
		users.remove(user.id);
	}
	
	public function hasSharedObject(remoteId:String):Bool
	{
		return (sharedObjects.get(remoteId) != null);
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
	
	public function addUserToSO(user:UserAdapter, remoteId:String, maxUsers:Int, needRestoreState:Bool):Bool
	{
		var so:SharedObject = getSharedObject(remoteId, maxUsers);
		if (so.addUser(user, needRestoreState))
		{
			user.sharedObjects.set(so.id, so);
			return true;
		}
		else
		{
			user.clientAPI.soFull(so.id);
			return false;
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