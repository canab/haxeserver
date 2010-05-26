package haxeserver.interfaces;

interface IClientAPI
{
	//setId
	function I(userId:Int):Void;
	
	//soConnect
	function C(remoteId:String, userId:Int):Void;
	
	//soDisconnet
	function D(remoteId:String, userId:Int):Void;
	
	// soRestore
	function R(remoteId:String, usersList:Array<Dynamic>, statesList:Array<Dynamic>, maxUsers:Int):Void;
	
	// soAction
	function A(remoteId:String, actionData:Array<Dynamic>):Void;
}