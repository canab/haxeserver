package haxeserver {
	import haxeserver.RemoteObject;
	import haxeserver.interfaces.IClientAPI;
	import haxe.remoting.SocketConnection;
	import haxelib.utils.ReflectUtil;
	import haxelib.common.utils.ArrayUtil;
	import haxe.remoting.Context;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.XMLSocket;
	import haxelib.common.events.EventSender;
	import flash.Boot;
	import haxeserver.ServerApi;
	public class RemoteConnection implements haxeserver.interfaces.IClientAPI{
		public function RemoteConnection() : void { if( !flash.Boot.skip_constructor ) {
			this.connected = false;
			this.connectEvent = new haxelib.common.events.EventSender(this);
			this.errorEvent = new haxelib.common.events.EventSender(this);
			this.remoteObjects = new Hash();
			this.classMap = new Array();
		}}
		
		public var connectEvent : haxelib.common.events.EventSender;
		public var errorEvent : haxelib.common.events.EventSender;
		public var serverAPI : haxeserver.ServerApi;
		public var remoteObjects : Hash;
		protected var classMap : Array;
		public var host : String;
		public var port : int;
		public var userId : int;
		public var errorMessage : String;
		protected var socket : flash.net.XMLSocket;
		protected var connected : Boolean;
		public function registerClass(classRef : Class) : void {
			this.classMap.push(classRef);
		}
		
		public function getInstance(typeId : int,instanceData : *) : * {
			var classRef : Class = this.classMap[typeId];
			var result : * = Type.createInstance(classRef,[]);
			haxelib.utils.ReflectUtil.copyFields(instanceData,result);
			return result;
		}
		
		public function getClassId(classRef : Class) : int {
			return haxelib.common.utils.ArrayUtil.indexOf(this.classMap,classRef);
		}
		
		public function connect() : void {
			if(this.connected) throw "Connection is already established";
			else this.createConnection();
		}
		
		protected function createConnection() : void {
			this.connected = true;
			this.socket = new flash.net.XMLSocket();
			this.socket.addEventListener(flash.events.Event.CONNECT,haxeserver.RemoteConnection.onConnect);
			this.socket.addEventListener(flash.events.IOErrorEvent.IO_ERROR,this.onError);
			this.socket.connect(this.host,this.port);
			var context : haxe.remoting.Context = new haxe.remoting.Context();
			context.addObject("client",this);
			var connection : haxe.remoting.SocketConnection = haxe.remoting.SocketConnection.create(this.socket,context);
			this.serverAPI = new haxeserver.ServerApi(connection.resolve("UserAdapter"));
		}
		
		protected function onError(e : flash.events.IOErrorEvent) : void {
			this.errorMessage = e.text;
			this.connected = false;
			this.errorEvent.sendEvent();
		}
		
		public function disconnect() : void {
			if(!this.connected) {
				this.connected = false;
				this.socket.close();
			}
		}
		
		public function createRemoteObject(remoteId : String) : haxeserver.RemoteObject {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote == null) {
				remote = new haxeserver.RemoteObject(this,remoteId);
				this.remoteObjects.set(remoteId,remote);
			}
			return remote;
		}
		
		public function disconnectRemoteObject(remoteId : String) : void {
			this.remoteObjects.remove(remoteId);
			this.serverAPI.soDisconnect(remoteId);
		}
		
		public function setId(value : int) : void {
			this.userId = value;
			this.connectEvent.sendEvent();
		}
		
		public function soCreate(remoteId : String,stateId : String,stateData : *,typeId : int) : void {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote != null) remote.applyCreateState(typeId,stateId,stateData);
		}
		
		public function soRestore(remoteId : String,usersList : Array,statesList : Array) : void {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote != null) remote.restore(usersList,statesList);
		}
		
		public function soUserConnect(remoteId : String,userId : int) : void {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote != null) remote.userConnect(userId);
		}
		
		public function soUserDisconnect(remoteId : String,userId : int) : void {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote != null) remote.userDisconnect(userId);
		}
		
		public function soSend(remoteId : String,func : String,stateId : String,state : *) : void {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote != null) remote.applySend(func,stateId,state);
		}
		
		public function soCall(remoteId : String,func : String,arguments : Array) : void {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote != null) remote.applyCall(func,arguments);
		}
		
		public function soRemove(remoteId : String,stateId : String) : void {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote != null) remote.applyRemove(stateId);
		}
		
		public function soCommand(remoteId : String,commandId : int,parameters : *) : void {
			var remote : haxeserver.RemoteObject = this.remoteObjects.get(remoteId);
			if(remote != null) remote.applyCommand(commandId,parameters);
		}
		
		static public function onConnect(e : flash.events.Event) : void {
			null;
		}
		
	}
}
