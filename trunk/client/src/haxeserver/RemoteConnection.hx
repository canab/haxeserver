/**
 * ...
 * @author Canab
 */

package haxeserver;

import flash.errors.Error;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.Lib;
import haxe.remoting.SocketProtocol;
import haxe.remoting.Context;
import haxe.remoting.SocketConnection;
import haxelib.common.events.EventSender;
import haxelib.common.utils.ArrayUtil;
import haxelib.common.utils.ReflectUtil;
import haxeserver.customprotocol.UnsizedSocketConnection;
import haxeserver.so.RemoteObject;

class ServerApi extends haxe.remoting.AsyncProxy<haxeserver.interfaces.IServerAPI>
{
}

class RemoteConnection
{
	static private var idCounter:Int = 0;
	
	public var connectEvent(default, null):EventSender<RemoteConnection>;
	public var errorEvent(default, null):EventSender<RemoteConnection>;
	public var serverAPI(default, null):ServerApi;
	public var remoteObjects(default, null):Hash<RemoteObject>;
	
	private var classMap:Array<Class<Dynamic>>;
	
	public var host:String;
	public var port:Int;
	
	public var id(default, null):Int;
	public var userId(default, null):Int;
	public var errorMessage(default, null):String;
	public var connected(default, null):Bool;
	public var connecting:Bool;
	
	private var socket:Socket;
	private var clientAPI:ClientAPI;
	
	public function new() 
	{
		id = idCounter++;
		connected = false;
		connecting = false;
		connectEvent = new EventSender(this);
		errorEvent = new EventSender(this);
		remoteObjects = new Hash<RemoteObject>();
		classMap = new Array<Class<Dynamic>>();
	}
	
	public function ping():Void 
	{
		var success:Bool = true;
		
		try
		{
			serverAPI.P();
		}
		catch (e:Error)
		{
			errorMessage = e.message;
			success = false;
		}
		
		if (!success)
			errorEvent.sendEvent();
	}	
	
	public function setUserId(value:Int):Void
	{
		userId = value;
		connecting = false;
		connected = true;
		connectEvent.sendEvent();
	}
	
	public function registerClass(classRef:Class<Dynamic>):Void 
	{
		classMap.push(classRef);
	}
	
	public function getTypedObject(typeId:Int):Dynamic
	{
		var classRef:Class<Dynamic> = classMap[typeId];
		return Type.createInstance(classRef, []);
	}
	
	public function getClassId(classRef:Class<Dynamic>):Int
	{
		return ArrayUtil.indexOf(classMap, classRef);
	}
	
	public function connect() 
	{
		if (connecting || connected)
			throw "Connection is already established";
		else
			createConnection();
	}
	
	private function createConnection():Void
	{
		connecting = true;
		
		socket = new haxe.remoting.Socket();
		socket.addEventListener(Event.CONNECT, onConnect);
		socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSequrityError);
		socket.connect(host, port);
		
		var context:Context = new Context();
		clientAPI = new ClientAPI(this);
		context.addObject("C", clientAPI);
		
		//var connection:SocketConnection = SocketConnection.create(socket, context);
		var connection:SocketConnection = UnsizedSocketConnection.create(socket, context);
		
		serverAPI = new ServerApi(connection.S);
		
		Lib.current.addEventListener(Event.ENTER_FRAME, processClienAPICalls);
	}
	
	private function processClienAPICalls(e:Event):Void 
	{
		clientAPI.processCallQueue();
	}
	
	public function disconnect() 
	{
		if (connecting || connected)
			closeConnection();
	}
	
	private function closeConnection():Void 
	{
		connected = false;
		connecting = false;
		socket.removeEventListener(Event.CONNECT, onConnect);
		socket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSequrityError);
		
		try
		{
			socket.close();
		}
		catch (e:Dynamic)
		{
		}
			
		remoteObjects = new Hash<RemoteObject>();
		
		Lib.current.removeEventListener(Event.ENTER_FRAME, processClienAPICalls);
	}
	
	private function onSequrityError(e:SecurityErrorEvent):Void 
	{
		disconnect();
		errorMessage = e.text;
		errorEvent.sendEvent();
	}
	
	private function onError(e:IOErrorEvent):Void 
	{
		disconnect();
		errorMessage = e.text;
		errorEvent.sendEvent();
	}
	
	public function onConnect(e:Event)
	{
	}
	
	public function addRemoteObject(object:RemoteObject):Void
	{
		if (remoteObjects.exists(object.id))
			throw object + " has been already added.";
		else
			remoteObjects.set(object.id, object);
	}
	
	public function removeRemoteObject(object:RemoteObject):Void
	{
		if (!remoteObjects.exists(object.id))
			throw object + " has not been added.";
		else
			remoteObjects.remove(object.id);
	}
}