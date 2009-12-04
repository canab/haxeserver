package  {
	import haxeserver.RemoteConnection;
	import flash.display.MovieClip;
	import flash.Lib;
	import haxe.Log;
	import test.VisualTest;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.Boot;
	public class ClientTest extends flash.display.MovieClip {
		public function ClientTest() : void { if( !flash.Boot.skip_constructor ) {
			super();
			if(this.stage != null) this.initialize();
			else this.addEventListener(flash.events.Event.ADDED_TO_STAGE,this.initialize);
		}}
		
		protected var connection : haxeserver.RemoteConnection;
		protected function initialize(e : flash.events.Event = null) : void {
			this.removeEventListener(flash.events.Event.ADDED_TO_STAGE,this.initialize);
			this.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			this.createConnection();
		}
		
		protected function createConnection() : void {
			this.connection = new haxeserver.RemoteConnection();
			this.connection.host = "localhost";
			this.connection.port = 4040;
			this.connection.connectEvent.addListener(this.onConnect);
			this.connection.errorEvent.addListener(this.onError);
			this.connection.connect();
			haxe.Log.trace("connecting to " + this.connection.host + ":" + this.connection.port + "...",{ fileName : "ClientTest.hx", lineNumber : 40, className : "ClientTest", methodName : "createConnection"});
		}
		
		protected function onError(sender : haxeserver.RemoteConnection) : void {
			haxe.Log.trace(this.connection.errorMessage,{ fileName : "ClientTest.hx", lineNumber : 45, className : "ClientTest", methodName : "onError"});
		}
		
		protected function onConnect(sender : haxeserver.RemoteConnection) : void {
			haxe.Log.trace("connected: id=" + this.connection.userId,{ fileName : "ClientTest.hx", lineNumber : 50, className : "ClientTest", methodName : "onConnect"});
			new test.VisualTest(this.connection,this);
		}
		
		static public function main() : void {
			flash.Lib.current.addChild(new ClientTest());
		}
		
	}
}
