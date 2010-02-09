/**
 * ...
 * @author Canab
 */

package haxeserver;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import haxe.remoting.SocketProtocol;
import haxe.remoting.Context;
import haxe.remoting.SocketConnection;
import haxelib.common.events.EventSender;
import haxelib.common.utils.ArrayUtil;
import haxelib.utils.ReflectUtil;
import haxeserver.interfaces.IClientAPI;

class ServerApi extends haxe.remoting.AsyncProxy<haxeserver.interfaces.IServerAPI>
{
}

class RemoteConnection implements IClientAPI
{
	public var connectEvent(default, null):EventSender<RemoteConnection>;
	public var errorEvent(default, null):EventSender<RemoteConnection>;
	public var serverAPI(default, null):ServerApi;
	public var remoteObjects(default, null):Hash<RemoteObject>;
	
	private var classMap:Array<Class<Dynamic>>;
	
	public var host:String;
	public var port:Int;
	
	public var userId(default, null):Int;
	public var errorMessage(default, null):String;
	
	private var socket:haxe.remoting.Socket;
	private var connected:Bool;
	
	public function new() 
	{
		connected = false;
		connectEvent = new EventSender<RemoteConnection>(this);
		errorEvent = new EventSender<RemoteConnection>(this);
		remoteObjects = new Hash<RemoteObject>();
		classMap = new Array<Class<Dynamic>>();
	}
	
	public function registerClass(classRef:Class<Dynamic>):Void 
	{
		classMap.push(classRef);
	}
	
	public function getInstance(typeId:Int, instanceData:Dynamic):Dynamic
	{
		var classRef:Class<Dynamic> = classMap[typeId];
		var result:Dynamic = Type.createInstance(classRef, []);
		ReflectUtil.copyFields(instanceData, result);
		return result;
	}
	
	public function getClassId(classRef:Class<Dynamic>):Int
	{
		return ArrayUtil.indexOf(classMap, classRef);
	}
	
	public function connect() 
	{
		if (connected)
			throw "Connection is already established";
		else
			createConnection();
	}
	
	private function createConnection():Void
	{
		connected = true;
		
		socket = new haxe.remoting.Socket();
		socket.addEventListener(Event.CONNECT, onConnect);
		socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSequrityError);
		socket.connect(host, port);
		
		var context:Context = new Context();
		context.addObject("C", this);
		var connection:SocketConnection = SocketConnection.create(socket, context);
		serverAPI = new ServerApi(connection.S);
	}
	
	private function onSequrityError(e:SecurityErrorEvent):Void 
	{
		connected = false;
		errorMessage = e.text;
		errorEvent.sendEvent();
	}
	
	private function onError(e:IOErrorEvent):Void 
	{
		connected = false;
		errorMessage = e.text;
		errorEvent.sendEvent();
	}
	
	public static function onConnect(e:Event)
	{
	}
	
	public function disconnect() 
	{
		if (!connected)
		{
			connected = false;
			socket.close();
		}
	}
	
	public function getRemoteObject(remoteId:String) :RemoteObject
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote == null)
		{
			remote = new RemoteObject(this, remoteId);
			remoteObjects.set(remoteId, remote);
		}
		return remote;
	}
	
	public function disconnectRemoteObject(remoteId:String)
	{
		remoteObjects.remove(remoteId);
		serverAPI.soDisconnect(remoteId);
	}
	
	////////////////////////////////////////////////////////////
	//
	// IClientAPI implementation
	//
	////////////////////////////////////////////////////////////
	
	public function setId(value:Int)
	{
		userId = value;
		connectEvent.sendEvent();
	}
	
	public function soCreate(remoteId:String, stateId:String, stateData:Dynamic, typeId:Int):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.applyCreateState(typeId, stateId, stateData);
	}
	
	public function soRestore(remoteId:String, usersList:Array<Dynamic>, statesList:Array<Dynamic>):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.restore(usersList, statesList);
	}
	
	public function soUserConnect(remoteId:String, userId:Int):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.applyUserConnect(userId);
	}
	
	public function soUserDisconnect(remoteId:String, userId:Int):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.applyUserDisconnect(userId);
	}
	
	public function soSend(remoteId:String, func:String, stateId:String, state:Dynamic):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.applySend(func, stateId, state);
	}
	
	public function soCall(remoteId:String, func:String, arguments:Array<Dynamic>):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.applyCall(func, arguments);
	}
	
	public function soRemove(remoteId:String, stateId:String):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.applyRemove(stateId);
	}
	
	public function soFull(remoteId:String):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.applyFull();
	}
	
	public function soCommand(remoteId:String, commandId:Int, parameters:Dynamic):Void
	{
		var remote:RemoteObject = remoteObjects.get(remoteId);
		if (remote != null)
			remote.applyCommand(commandId, parameters);
	}
}