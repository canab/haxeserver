package haxeserver.core;

import haxeserver.interfaces.IServerAPI;
import haxeserver.services.ServiceBase;

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
			application.addUserToSO(this, remoteId, maxUsers, true);
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
			application.removeUserFromSO(this, remoteId);
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
			var ownerId:Int = (autoRemove) ? this.id : -1;
			sharedObjects.get(remoteId).createState(ownerId, typeId, stateId, stateData);
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
			sharedObjects.get(remoteId).sendState(func, stateId, stateData);
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
			sharedObjects.get(remoteId).lockState(this, func, stateId, stateData);
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
			sharedObjects.get(remoteId).unLockState(this, func, stateId, stateData);
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
			sharedObjects.get(remoteId).call(func, arguments);
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
			sharedObjects.get(remoteId).removeState(stateId);
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
			sharedObjects.get(remoteId).sendCommand(commandId, parameters);
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
			application.logger.info('SERVICE: ' + className + '|' + func + '|' + args);
			var service:ServiceBase = Type.createInstance(Type.resolveClass(className), []);
			service.currentUser = this;
			var method:Dynamic = Reflect.field(service, func);
			var result:Dynamic = Reflect.callMethod(service, method, args);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
		return result;
	}
	
}