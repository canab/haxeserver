/**
 * ...
 * @author Canab
 */
package haxeserver.core;
import haxe.remoting.Context;
import haxe.remoting.SocketConnection;
import haxeserver.customprotocol.UnsizedRemotingServer;
import haxeserver.core.profiler.Profiler;
import haxeserver.core.so.SharedObject;
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
	public var profiler(default, null):Profiler;
	
	private var idCounter:Int;
	//private var server:ThreadRemotingServer;
	private var server:UnsizedRemotingServer;
	
	public function new()
	{
		idCounter = 0;
		logger = new Logger("log/server.log", 1024 * 1024);
		users = new IntHash<UserAdapter>();
		sharedObjects = new Hash<SharedObject>();
		profiler = new Profiler();
	}
	
	public function initialize():Void
	{
		config = new ApplicationConfig("server-config.xml");
	}
	
	public function createServer():Void
	{
		try
		{
			//server = new ThreadRemotingServer();
			server = new UnsizedRemotingServer();
			server.initClientApi = initClientAPI;
			server.clientDisconnected = clientDisconnected;
			logger.info("================");
			logger.info("== HaxeServer ==");
			logger.info("================");
			logger.info("Starting server at " + config.host + ':' + config.port);
			server.run(config.host, config.port);
		}
		catch (e:Dynamic)
		{
			logger.exception(e);
		}
	}
	
	private function initClientAPI(connection:SocketConnection, context:Context)
	{
		try
		{
			var userId:Int = idCounter++;
			logger.info("user connected, id=" + userId);
			
			var adapter:UserAdapter = new UserAdapter(connection, userId);
			context.addObject("S", adapter);
			users.set(userId, adapter);
			(cast connection).__user = adapter;
			
			connection.setErrorHandler(onConnectionError);
		}
		catch (e:Dynamic)
		{
			logger.exception(e);
		}
	}
	
	private function onConnectionError(e:Dynamic):Void
	{
		logger.exception(e);
	}
	
	private function clientDisconnected(cannection:SocketConnection) 
	{
		try
		{
			var user:UserAdapter = (cast cannection).__user;
			for (so in user.sharedObjects)
			{
				removeUserFromSO(user, so.id);
			}
			logger.info("user disconnected, id=" + user.id);
			users.remove(user.id);
		}
		catch (e:Dynamic)
		{
			logger.exception(e);
		}
	}
	
	public function hasSharedObject(remoteId:String):Bool
	{
		return (sharedObjects.get(remoteId) != null);
	}
	
	public function getSharedObject(remoteId:String, maxUsers:Int, name:String):SharedObject
	{
		var so:SharedObject = sharedObjects.get(remoteId);
		if (so == null)
		{
			so = new SharedObject(remoteId);
			so.maxUsers = maxUsers;
			so.name = name;
			sharedObjects.set(remoteId, so);
		}
		return so;
	}
	
	public function addUserToSO(user:UserAdapter, remoteId:String,
		maxUsers:Int, name:String, needRestoreState:Bool):Bool
	{
		var so:SharedObject = getSharedObject(remoteId, maxUsers, name);
		var result:Bool = so.addUser(user, needRestoreState);
		if (result)
			user.sharedObjects.set(so.id, so);
		return result;
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