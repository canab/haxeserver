package haxeserver.core;

import haxeserver.interfaces.IServerAPI;
import haxeserver.services.ServiceBase;
import neko.Sys;

import haxe.remoting.AsyncProxy;
import haxe.remoting.SocketConnection;

class ClientApi extends AsyncProxy<haxeserver.interfaces.IClientAPI>
{
}

class UserAdapter implements IServerAPI
{
	public var id(default, null):Int;
	public var login:String;
	public var clientAPI(default, null):ClientApi;
	
	public var sharedObjects(default, null):Hash<SharedObject>;
	
	private var application:Application;
	
	public function new(connection:SocketConnection, userId:Int)
	{
		id = userId;
		login = null;
		clientAPI = new ClientApi(connection.C);
		clientAPI.setId(id);
		sharedObjects = new Hash<SharedObject>();
		application = Application.instance;
	}
	
	public function soConnect(remoteId:String, maxUsers:Int)
	{
		try
		{
			var t = Sys.time();
			
			application.addUserToSO(this, remoteId, maxUsers, true);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function soDisconnect(remoteId:String)
	{
		try
		{
			var t = Sys.time();
			
			application.removeUserFromSO(this, remoteId);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function soCreate(autoRemove:Bool, typeId:Int, remoteId:String, stateId:String, stateData:Dynamic):Void
	{
		try
		{
			var t = Sys.time();
			
			var ownerId:Int = (autoRemove) ? this.id : -1;
			sharedObjects.get(remoteId).createState(ownerId, typeId, stateId, stateData);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function soSend(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void
	{
		try
		{
			var t = Sys.time();
			
			sharedObjects.get(remoteId).sendState(func, stateId, stateData);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function soLock(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void
	{
		try
		{
			var t = Sys.time();
			
			sharedObjects.get(remoteId).lockState(this, func, stateId, stateData);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function soUnLock(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void
	{
		try
		{
			var t = Sys.time();
			
			sharedObjects.get(remoteId).unLockState(this, func, stateId, stateData);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function soCall(remoteId:String, func:String, arguments:Array<Dynamic>):Void
	{
		try
		{
			var t = Sys.time();
			
			sharedObjects.get(remoteId).call(func, arguments);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function soRemove(remoteId:String, stateId:String)
	{
		try
		{
			var t = Sys.time();
			
			sharedObjects.get(remoteId).removeState(stateId);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function soCommand(remoteId:String, commandId:Int, parameters:Dynamic)
	{
		try
		{
			var t = Sys.time();
			
			sharedObjects.get(remoteId).sendCommand(commandId, parameters);
			
			application.profiler.addCall(here.methodName, Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	public function callService(className:String, func:String, args:Array<Dynamic>):Dynamic
	{
		var result:Dynamic = null;
		try
		{
			var logServiceName:String = className.substr(className.lastIndexOf('.') + 1) + '.' + func;
			application.logger.info(logServiceName + args);
			
			var t = Sys.time();
			
			var service:ServiceBase = Type.createInstance(Type.resolveClass(className), []);
			service.currentUser = this;
			var method:Dynamic = Reflect.field(service, func);
			result = Reflect.callMethod(service, method, args);
			
			t = Sys.time() - t;
			application.profiler.addCall(logServiceName, t);
			
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
		return result;
	}
	
}