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
import haxelib.common.utils.ReflectUtil;

class ServerApi extends haxe.remoting.AsyncProxy<haxeserver.interfaces.IServerAPI>
{
}

class RemoteConnection
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
	private var clientAPI:ClientAPI;
	private var connected:Bool;
	
	public function new() 
	{
		connected = false;
		connectEvent = new EventSender<RemoteConnection>(this);
		errorEvent = new EventSender<RemoteConnection>(this);
		remoteObjects = new Hash<RemoteObject>();
		classMap = new Array<Class<Dynamic>>();
	}
	
	public function setUserId(value:Int):Void
	{
		userId = value;
		connectEvent.sendEvent();
	}
	
	public function registerClass(classRef:Class<Dynamic>):Void 
	{
		classMap.push(classRef);
	}
	
	public function getTypedObject(typeId:Int, instanceData:Dynamic):Dynamic
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
	
	public function disconnect() 
	{
		if (connected)
			closeConnection();
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
		clientAPI = new ClientAPI(this);
		context.addObject("C", clientAPI);
		var connection:SocketConnection = SocketConnection.create(socket, context);
		serverAPI = new ServerApi(connection.S);
	}
	
	private function closeConnection():Void 
	{
		socket.removeEventListener(Event.CONNECT, onConnect);
		socket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSequrityError);
		connected = false;
		socket.close();
		remoteObjects = new Hash<RemoteObject>();
	}
	
	private function onSequrityError(e:SecurityErrorEvent):Void 
	{
		connected = false;
		errorMessage = e.text;
		errorEvent.sendEvent();
	}
	
	private function onError(e:IOErrorEvent):Void 
	{
		disconnect();
		errorMessage = e.text;
		errorEvent.sendEvent();
	}
	
	public static function onConnect(e:Event)
	{
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
}