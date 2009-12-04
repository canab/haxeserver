package haxe.remoting {
	import haxe.Serializer;
	import haxe.remoting.Context;
	import haxe.Unserializer;
	import flash.Boot;
	import flash.net.XMLSocket;
	public class SocketProtocol {
		public function SocketProtocol(sock : flash.net.XMLSocket = null,ctx : haxe.remoting.Context = null) : void { if( !flash.Boot.skip_constructor ) {
			this.socket = sock;
			this.context = ctx;
		}}
		
		public var socket : flash.net.XMLSocket;
		public var context : haxe.remoting.Context;
		protected function decodeChar(c : int) : * {
			if(c >= 65 && c <= 90) return c - 65;
			if(c >= 97 && c <= 122) return c - 97 + 26;
			if(c >= 48 && c <= 57) return c - 48 + 52;
			if(c == 43) return 62;
			if(c == 47) return 63;
			return null;
		}
		
		protected function encodeChar(c : int) : * {
			if(c < 0) return null;
			if(c < 26) return c + 65;
			if(c < 52) return (c - 26) + 97;
			if(c < 62) return (c - 52) + 48;
			if(c == 62) return 43;
			if(c == 63) return 47;
			return null;
		}
		
		public function messageLength(c1 : int,c2 : int) : * {
			var e1 : * = this.decodeChar(c1);
			var e2 : * = this.decodeChar(c2);
			if(e1 == null || e2 == null) return null;
			return (e1 << 6) | e2;
		}
		
		public function encodeMessageLength(len : int) : * {
			var c1 : * = this.encodeChar(len >> 6);
			if(c1 == null) throw "Message is too big";
			var c2 : * = this.encodeChar(len & 63);
			return { c1 : c1, c2 : c2}
		}
		
		public function sendRequest(path : Array,params : Array) : void {
			var s : haxe.Serializer = new haxe.Serializer();
			s.serialize(true);
			s.serialize(path);
			s.serialize(params);
			this.sendMessage(s.toString());
		}
		
		public function sendAnswer(answer : *,isException : * = null) : void {
			var s : haxe.Serializer = new haxe.Serializer();
			s.serialize(false);
			if(isException) s.serializeException(answer);
			else s.serialize(answer);
			this.sendMessage(s.toString());
		}
		
		public function sendMessage(msg : String) : void {
			var e : * = this.encodeMessageLength(msg.length + 3);
			this.socket.send(String.fromCharCode(e.c1) + String.fromCharCode(e.c2) + msg);
		}
		
		public var decodeData : Function = function(data : String) : String {
			return data;
		}
		public function isRequest(data : String) : Boolean {
			return function($this:SocketProtocol) : Boolean {
				var $r : Boolean;
				switch(haxe.Unserializer.run(data)) {
				case true:{
					$r = true;
				}break;
				case false:{
					$r = false;
				}break;
				default:{
					$r = function($this:SocketProtocol) : Boolean {
						var $r2 : Boolean;
						throw "Invalid data";
						return $r2;
					}($this);
				}break;
				}
				return $r;
			}(this);
		}
		
		public function processRequest(data : String,onError : Function = null) : void {
			var s : haxe.Unserializer = new haxe.Unserializer(data);
			var result : *;
			var isException : Boolean = false;
			if(s.unserialize() != true) throw "Not a request";
			var path : Array = s.unserialize();
			var args : Array = s.unserialize();
			try {
				if(this.context == null) throw "No context is shared";
				result = this.context.call(path,args);
			}
			catch( e : * ){
				result = e;
				isException = true;
			}
			this.sendAnswer(result,isException);
			if(isException && onError != null) onError(path,args,result);
		}
		
		public function processAnswer(data : String) : * {
			var s : haxe.Unserializer = new haxe.Unserializer(data);
			if(s.unserialize() != false) throw "Not an answer";
			return s.unserialize();
		}
		
	}
}
