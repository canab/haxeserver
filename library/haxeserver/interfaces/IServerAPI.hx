package haxeserver.interfaces;

interface IServerAPI
{
	function soConnect(remoteId:String, maxUsers:Int):Void;
	function soDisconnect(remoteId:String):Void;
	function soCreate(autoRemove:Bool, typeId:Int, remoteId:String, stateId:String, stateData:Dynamic):Void;
	function soSend(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void;
	function soLock(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void;
	function soUnLock(remoteId:String, func:String, stateId:String, stateData:Dynamic):Void;
	function soCall(remoteId:String, func:String, arguments:Array<Dynamic>):Void;
	function soRemove(remoteId:String, stateId:String):Void;
	function soCommand(remoteId:String, commandId:Int, parameters:Dynamic):Void;
	function callService(className:String, func:String, args:Array<Dynamic>):Dynamic;
}