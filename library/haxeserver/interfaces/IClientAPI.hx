package haxeserver.interfaces;

interface IClientAPI
{
	function setId(userId:Int):Void;
	function soUserConnect(remoteId:String, userId:Int):Void;
	function soUserDisconnect(remoteId:String, userId:Int):Void;
	
	// action
	function A(remoteId:String, actionData:Array<Dynamic>):Void;
	
	function soRestore(remoteId:String, usersList:Array<Dynamic>, statesList:Array<Dynamic>):Void;
	function soFull(remoteId:String):Void;
}