package haxeserver.interfaces {
	public interface IClientAPI {
		function setId(userId : int) : void ;
		function soCreate(remoteId : String,stateId : String,state : *,typeId : int) : void ;
		function soSend(remoteId : String,func : String,stateId : String,state : *) : void ;
		function soCall(remoteId : String,func : String,arguments : Array) : void ;
		function soRemove(remoteId : String,stateId : String) : void ;
		function soCommand(remoteId : String,commandId : int,parameters : *) : void ;
		function soRestore(remoteId : String,usersList : Array,statesList : Array) : void ;
		function soUserConnect(remoteId : String,userId : int) : void ;
		function soUserDisconnect(remoteId : String,userId : int) : void ;
	}
}
