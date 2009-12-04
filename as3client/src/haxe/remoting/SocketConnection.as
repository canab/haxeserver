package haxe.remoting {
	import haxe.remoting.AsyncConnection;
	import flash.events.DataEvent;
	import haxe.remoting.SocketProtocol;
	import haxe.remoting.Context;
	import flash.net.XMLSocket;
	import flash.Boot;
	public dynamic class SocketConnection implements haxe.remoting.AsyncConnection{
		public function SocketConnection(data : * = null,path : Array = null) : void { if( !flash.Boot.skip_constructor ) {
			this.__data = data;
			this.__path = path;
		}}
		
		protected var __path : Array;
		protected var __data : *;
		public function resolve(name : String) : haxe.remoting.AsyncConnection {
			var s : haxe.remoting.SocketConnection = new haxe.remoting.SocketConnection(this.__data,this.__path.copy());
			s.__path.push(name);
			return s;
		}
		
		public function call(params : Array,onResult : Function = null) : void {
			try {
				this.__data.protocol.sendRequest(this.__path,params);
				this.__data.results.add({ onResult : onResult, onError : this.__data.error});
			}
			catch( e : * ){
				this.__data.error(e);
			}
		}
		
		public function setErrorHandler(h : Function) : void {
			this.__data.error = h;
		}
		
		public function setErrorLogger(h : Function) : void {
			this.__data.log = h;
		}
		
		public function setProtocol(p : haxe.remoting.SocketProtocol) : void {
			this.__data.protocol = p;
		}
		
		public function getProtocol() : haxe.remoting.SocketProtocol {
			return this.__data.protocol;
		}
		
		public function close() : void {
			try {
				this.__data.protocol.socket.close();
			}
			catch( e : * ){
				null;
			}
		}
		
		public function processMessage(data : String) : void {
			var request : Boolean;
			var proto : haxe.remoting.SocketProtocol = this.__data.protocol;
			data = proto.decodeData(data);
			try {
				request = proto.isRequest(data);
			}
			catch( e : * ){
				var msg : String = Std.string(e) + " (in " + StringTools.urlEncode(data) + ")";
				this.__data.error(msg);
				return;
			}
			if(request) {
				try {
					proto.processRequest(data,this.__data.log);
				}
				catch( e2 : * ){
					this.__data.error(e2);
				}
				return;
			}
			var f : * = this.__data.results.pop();
			if(f == null) {
				this.__data.error("No response excepted (" + data + ")");
				return;
			}
			var ret : *;
			try {
				ret = proto.processAnswer(data);
			}
			catch( e3 : * ){
				f.onError(e3);
				return;
			}
			if(f.onResult != null) f.onResult(ret);
		}
		
		protected function defaultLog(path : *,args : *,e : *) : void {
			var astr : String, estr : String;
			try {
				astr = args.join(",");
			}
			catch( e1 : * ){
				astr = "???";
			}
			try {
				estr = Std.string(e);
			}
			catch( e12 : * ){
				estr = "???";
			}
			var header : String = "Error in call to " + path.join(".") + "(" + astr + ") : ";
			this.__data.error(header + estr);
		}
		
		static public function create(s : flash.net.XMLSocket,ctx : haxe.remoting.Context = null) : haxe.remoting.SocketConnection {
			var data : * = { protocol : new haxe.remoting.SocketProtocol(s,ctx), results : new List(), error : function(e : *) : void {
				throw e;
			}, log : null}
			var sc : haxe.remoting.SocketConnection = new haxe.remoting.SocketConnection(data,[]);
			data.log = sc.defaultLog;
			s.addEventListener(flash.events.DataEvent.DATA,function(e : flash.events.DataEvent) : void {
				var data1 : String = e.data;
				var msgLen : * = sc.__data.protocol.messageLength(data1["charCodeAt"](0),data1["charCodeAt"](1));
				if(msgLen == null || data1.length != msgLen - 1) {
					sc.__data.error("Invalid message header");
					return;
				}
				sc.processMessage(e.data.substr(2,e.data.length - 2));
			});
			return sc;
		}
		
	}
}
