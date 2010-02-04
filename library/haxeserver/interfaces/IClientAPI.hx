package haxeserver.interfaces;

interface IClientAPI
{
	function setId(userId:Int):Void;
	function soCreate(remoteId:String, stateId:String, state:Dynamic, typeId:Int):Void;
	function soSend(remoteId:String, func:String, stateId:String, state:Dynamic):Void;
	function soCall(remoteId:String, func:String, arguments:Array<Dynamic>):Void;
	function soRemove(remoteId:String, stateId:String):Void;
	function soCommand(remoteId:String, commandId:Int, parameters:Dynamic):Void;
	function soRestore(remoteId:String, usersList:Array<Dynamic>, statesList:Array<Dynamic>):Void;
	function soUserConnect(remoteId:String, userId:Int):Void;
	function soUserDisconnect(remoteId:String, userId:Int):Void;
	function soFull(remoteId:String):Void;
}