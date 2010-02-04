package haxeserver.core;

import haxeserver.interfaces.IServerAPI;
import haxeserver.services.SOService;

import haxe.remoting.AsyncProxy;
import haxe.remoting.SocketConnection;

class ClientApi extends AsyncProxy<haxeserver.interfaces.IClientAPI>
{
}

class UserAdapter implements IServerAPI
{
	public var id(default, null):Int;
	public var clientAPI(default, null):ClientApi;
	
	public var sharedObjects(default, null):Hash<SharedObject>;
	
	private var application:Application;
	
	public function new(connection:SocketConnection, userId:Int)
	{
		id = userId;
		clientAPI = new ClientApi(connection.C);
		clientAPI.setId(id);
		sharedObjects = new Hash<SharedObject>();
		application = Application.instance;
	}
	
	public function soConnect(remoteId:String, maxUsers:Int)
	{
		application.addUserToSO(this, remoteId, maxUsers);
	}
	
	public function soDisconnect(remoteId:String)
	{
		application.removeUserFromSO(this, remoteId);
	}
	
	public function soCreate(autoRemove:Bool, typeId:Int, remoteId:String, stateId:String, stateData:Dynamic):Void
	{
		var ownerId:Int = (autoRemove) ? this.id : -1;
		sharedObjects.get(remoteId).createState(ownerId, typeId, stateId, stateData);
	}
	
	public function soSend(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void
	{
		sharedObjects.get(remoteId).sendState(func, stateId, stateData);
	}
	
	public function soLock(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void
	{
		sharedObjects.get(remoteId).lockState(this, func, stateId, stateData);
	}
	
	public function soUnLock(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void
	{
		sharedObjects.get(remoteId).unLockState(this, func, stateId, stateData);
	}
	
	public function soCall(remoteId:String, func:String, arguments:Array<Dynamic>):Void
	{
		sharedObjects.get(remoteId).call(func, arguments);
	}
	
	public function soRemove(remoteId:String, stateId:String)
	{
		sharedObjects.get(remoteId).removeState(stateId);
	}
	
	public function soCommand(remoteId:String, commandId:Int, parameters:Dynamic)
	{
		sharedObjects.get(remoteId).sendCommand(commandId, parameters);
	}
	
	public function callService(className:String, func:String, args:Array<Dynamic>):Dynamic
	{
		var service:Dynamic = Type.createInstance(Type.resolveClass(className), []);
		var method:Dynamic = Reflect.field(service, func);
		var result:Dynamic = Reflect.callMethod(service, method, args);
		return result;
	}
	
}