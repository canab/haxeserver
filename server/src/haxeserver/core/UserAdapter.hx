﻿package haxeserver.core;

import haxeserver.core.so.SharedObject;
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
		clientAPI.I(id);
		sharedObjects = new Hash<SharedObject>();
		application = Application.instance;
	}
	
	//ping
	public function P():Void
	{
	}
	
	//callService
	public function S(className:String, func:String, args:Array<Dynamic>):Dynamic
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
			
			application.profiler.addCall(logServiceName, Sys.time() - t);
			
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
		return result;
	}
	
	// soConnect
	public function C(remoteId:String, maxUsers:Int, name:String):Bool
	{
		var result:Bool;
		try
		{
			var t = Sys.time();
			
			result = application.addUserToSO(this, remoteId, maxUsers, name, true);
			
			application.profiler.addCall('soConnect', Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			result = false;
			application.logger.exception(e);
		}
		return result;
	}
	
	// soDisconnect	
	public function D(remoteId:String)
	{
		try
		{
			var t = Sys.time();
			
			application.removeUserFromSO(this, remoteId);
			
			application.profiler.addCall('soDisconnect', Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	// soAction
	public function A(remoteId:String, actionData:Array<Dynamic>):Void 
	{
		try
		{
			var t = Sys.time();
			sharedObjects.get(remoteId).doAction(this, actionData);
			application.profiler.addCall('soAction', Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
	
	// soLock
	public function L(remoteId:String, stateId:String):Bool
	{
		var result:Bool;
		try
		{
			var t = Sys.time();
			
			result = sharedObjects.get(remoteId).lockState(this, stateId);
			
			application.profiler.addCall("soLock", Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
			result = false;
		}
		return result;
	}
	
	// soUnlock
	public function U(remoteId:String, stateId:String):Void
	{
		try
		{
			var t = Sys.time();
			
			sharedObjects.get(remoteId).unlockState(this, stateId);
			
			application.profiler.addCall("soUnlock", Sys.time() - t);
		}
		catch (e:Dynamic)
		{
			application.logger.exception(e);
		}
	}
}