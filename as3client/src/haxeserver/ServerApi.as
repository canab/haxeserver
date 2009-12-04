package haxeserver {
	import haxeserver.interfaces.Async_IServerAPI;
	import flash.Boot;
	import haxe.remoting.AsyncConnection;
	public class ServerApi extends haxeserver.interfaces.Async_IServerAPI {
		public function ServerApi(c : haxe.remoting.AsyncConnection = null) : void { if( !flash.Boot.skip_constructor ) {
			super(c);
		}}
		
	}
}
