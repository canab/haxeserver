package haxeserver {
	import haxeserver.IRemoteClient;
	import haxelib.common.commands.ICommand;
	import haxeserver.RemoteConnection;
	import haxelib.utils.ReflectUtil;
	import haxe.Log;
	import flash.Boot;
	public class RemoteObject {
		public function RemoteObject(remoteConnection : haxeserver.RemoteConnection = null,remoteId : String = null) : void { if( !flash.Boot.skip_constructor ) {
			this.connection = remoteConnection;
			this.id = remoteId;
			this.ready = false;
			this.connected = false;
			this.states = new Hash();
			this.users = new List();
		}}
		
		public var id : String;
		public var states : Hash;
		public var users : List;
		public var client : haxeserver.IRemoteClient;
		public function get userId() : int { return getUserId(); }
		protected var $userId : int;
		public function getUserId() : int {
			return this.connection.userId;
		}
		
		public var connected : Boolean;
		public var ready : Boolean;
		protected var connection : haxeserver.RemoteConnection;
		public function connect(client : haxeserver.IRemoteClient) : void {
			if(this.connected) {
				throw "RemoteObject (id=" + this.id + ") already connected";
			}
			else {
				this.client = client;
				this.connected = true;
				this.connection.serverAPI.soConnect(this.id);
			}
		}
		
		public function disconnect() : void {
			this.connection.disconnectRemoteObject(this.id);
		}
		
		public function restore(usersList : Array,statesList : Array) : void {
			{
				var _g : int = 0;
				while(_g < usersList.length) {
					var userId : * = usersList[_g];
					++_g;
					this.userConnect(userId);
				}
			}
			{
				var _g2 : int = 0;
				while(_g2 < statesList.length) {
					var state : * = statesList[_g2];
					++_g2;
					var stateArray : Array = state;
					var stateId : String = stateArray[0];
					var typeId : int = stateArray[1];
					var stateData : * = stateArray[2];
					this.applyCreateState(typeId,stateId,stateData);
				}
			}
			this.ready = true;
			this.client.onReady();
		}
		
		public function createState(stateId : String,state : *,autoRemove : Boolean = false) : void {
			var typeId : int = this.connection.getClassId(Type.getClass(state));
			var stateData : * = { }
			haxelib.utils.ReflectUtil.copyFields(state,stateData);
			this.connection.serverAPI.soCreate(autoRemove,typeId,this.id,stateId,stateData);
		}
		
		public function removeState(stateId : String) : void {
			this.connection.serverAPI.soRemove(this.id,stateId);
		}
		
		public function call(func : String,arguments : Array) : void {
			this.connection.serverAPI.soCall(this.id,func,arguments);
		}
		
		public function sendState(func : String,stateId : String,state : *) : void {
			var stateData : * = { }
			haxelib.utils.ReflectUtil.copyFields(state,stateData);
			this.connection.serverAPI.soSend(this.id,func,stateId,stateData);
		}
		
		public function sendCommand(command : haxelib.common.commands.ICommand) : void {
			var commandId : int = 0;
			var parameters : * = "params";
			this.connection.serverAPI.soCommand(this.id,commandId,parameters);
		}
		
		public function userConnect(userId : int) : void {
			try {
				this.users.add(userId);
				this.client.onUserConnect(userId);
			}
			catch( e : Error ){
				haxe.Log.trace(e.message,{ fileName : "RemoteObject.hx", lineNumber : 120, className : "haxeserver.RemoteObject", methodName : "userConnect"});
				haxe.Log.trace(e.getStackTrace(),{ fileName : "RemoteObject.hx", lineNumber : 121, className : "haxeserver.RemoteObject", methodName : "userConnect"});
			}
		}
		
		public function userDisconnect(userId : int) : void {
			try {
				this.users.remove(userId);
				this.client.onUserDisconnect(userId);
			}
			catch( e : Error ){
				haxe.Log.trace(e.message,{ fileName : "RemoteObject.hx", lineNumber : 134, className : "haxeserver.RemoteObject", methodName : "userDisconnect"});
				haxe.Log.trace(e.getStackTrace(),{ fileName : "RemoteObject.hx", lineNumber : 135, className : "haxeserver.RemoteObject", methodName : "userDisconnect"});
			}
		}
		
		public function applyCreateState(typeId : int,stateId : String,stateData : *) : void {
			try {
				var state : *;
				if(typeId == -1) state = stateData;
				else state = this.connection.getInstance(typeId,stateData);
				this.states.set(stateId,state);
				this.client.onStateCreated(stateId,state);
			}
			catch( e : Error ){
				haxe.Log.trace(e.message,{ fileName : "RemoteObject.hx", lineNumber : 154, className : "haxeserver.RemoteObject", methodName : "applyCreateState"});
				haxe.Log.trace(e.getStackTrace(),{ fileName : "RemoteObject.hx", lineNumber : 155, className : "haxeserver.RemoteObject", methodName : "applyCreateState"});
			}
		}
		
		public function applyRemove(stateId : String) : void {
			try {
				var state : * = this.states.get(stateId);
				this.states.remove(stateId);
				this.client.onStateRemoved(stateId,state);
			}
			catch( e : Error ){
				haxe.Log.trace(e.message,{ fileName : "RemoteObject.hx", lineNumber : 169, className : "haxeserver.RemoteObject", methodName : "applyRemove"});
				haxe.Log.trace(e.getStackTrace(),{ fileName : "RemoteObject.hx", lineNumber : 170, className : "haxeserver.RemoteObject", methodName : "applyRemove"});
			}
		}
		
		public function applySend(func : String,stateId : String,stateData : *) : void {
			try {
				var state : * = this.states.get(stateId);
				haxelib.utils.ReflectUtil.copyFields(stateData,state);
				this.client.onStateChanged(stateId,state);
				if(func != null) this.callClient(func,[stateId,state]);
			}
			catch( e : Error ){
				haxe.Log.trace(e.message,{ fileName : "RemoteObject.hx", lineNumber : 186, className : "haxeserver.RemoteObject", methodName : "applySend"});
				haxe.Log.trace(e.getStackTrace(),{ fileName : "RemoteObject.hx", lineNumber : 187, className : "haxeserver.RemoteObject", methodName : "applySend"});
			}
		}
		
		public function applyCall(func : String,arguments : Array) : void {
			try {
				this.callClient(func,arguments);
			}
			catch( e : Error ){
				haxe.Log.trace(e.message,{ fileName : "RemoteObject.hx", lineNumber : 199, className : "haxeserver.RemoteObject", methodName : "applyCall"});
				haxe.Log.trace(e.getStackTrace(),{ fileName : "RemoteObject.hx", lineNumber : 200, className : "haxeserver.RemoteObject", methodName : "applyCall"});
			}
		}
		
		public function applyCommand(commandId : int,parameters : *) : void {
			try {
				this.client.onCommand(null);
			}
			catch( e : Error ){
				haxe.Log.trace(e.message,{ fileName : "RemoteObject.hx", lineNumber : 212, className : "haxeserver.RemoteObject", methodName : "applyCommand"});
				haxe.Log.trace(e.getStackTrace(),{ fileName : "RemoteObject.hx", lineNumber : 213, className : "haxeserver.RemoteObject", methodName : "applyCommand"});
			}
		}
		
		protected function callClient(func : String,arguments : Array) : void {
			try {
				Reflect.callMethod(this.client,Reflect.field(this.client,func),arguments);
			}
			catch( error : Error ){
				haxe.Log.trace("clientCall Error " + error.message,{ fileName : "RemoteObject.hx", lineNumber : 225, className : "haxeserver.RemoteObject", methodName : "callClient"});
				haxe.Log.trace(error.getStackTrace(),{ fileName : "RemoteObject.hx", lineNumber : 226, className : "haxeserver.RemoteObject", methodName : "callClient"});
			}
		}
		
	}
}
