package haxeserver {
	import haxeserver.IRemoteClient;
	import haxelib.common.commands.ICommand;
	public class RemoteClient implements haxeserver.IRemoteClient{
		public function RemoteClient() : void {
			null;
		}
		
		public function onReady() : void {
			null;
		}
		
		public function onUserConnect(userId : int) : void {
			null;
		}
		
		public function onUserDisconnect(userId : int) : void {
			null;
		}
		
		public function onStateCreated(stateId : String,state : *) : void {
			null;
		}
		
		public function onStateChanged(stateId : String,state : *) : void {
			null;
		}
		
		public function onStateRemoved(stateId : String,state : *) : void {
			null;
		}
		
		public function onCommand(command : haxelib.common.commands.ICommand) : void {
			null;
		}
		
	}
}
