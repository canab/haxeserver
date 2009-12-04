package haxeserver.interfaces {
	import flash.Boot;
	import haxe.remoting.AsyncConnection;
	public class Async_IServerAPI {
		public function Async_IServerAPI(c : haxe.remoting.AsyncConnection = null) : void { if( !flash.Boot.skip_constructor ) {
			this.__cnx = c;
		}}
		
		protected var __cnx : haxe.remoting.AsyncConnection;
		public function soConnect(remoteId : String) : void {
			this.__cnx.resolve("soConnect").call([remoteId],null);
		}
		
		public function soDisconnect(remoteId : String) : void {
			this.__cnx.resolve("soDisconnect").call([remoteId],null);
		}
		
		public function soCreate(autoRemove : Boolean,typeId : int,remoteId : String,stateId : String,stateData : *) : void {
			this.__cnx.resolve("soCreate").call([autoRemove,typeId,remoteId,stateId,stateData],null);
		}
		
		public function soSend(remoteId : String,func : String,stateId : String,stateData : *) : void {
			this.__cnx.resolve("soSend").call([remoteId,func,stateId,stateData],null);
		}
		
		public function soCall(remoteId : String,func : String,arguments : Array) : void {
			this.__cnx.resolve("soCall").call([remoteId,func,arguments],null);
		}
		
		public function soRemove(remoteId : String,stateId : String) : void {
			this.__cnx.resolve("soRemove").call([remoteId,stateId],null);
		}
		
		public function soCommand(remoteId : String,commandId : int,parameters : *) : void {
			this.__cnx.resolve("soCommand").call([remoteId,commandId,parameters],null);
		}
		
	}
}
