package haxeserver {
	import haxelib.common.commands.ICommand;
	public interface IRemoteClient {
		function onReady() : void ;
		function onUserConnect(userId : int) : void ;
		function onUserDisconnect(userId : int) : void ;
		function onStateCreated(stateId : String,state : *) : void ;
		function onStateChanged(stateId : String,state : *) : void ;
		function onStateRemoved(stateId : String,state : *) : void ;
		function onCommand(command : haxelib.common.commands.ICommand) : void ;
	}
}
