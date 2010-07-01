package haxeserver.interfaces;

interface IServerAPI
{
	//callService
	function S(className:String, func:String, args:Array<Dynamic>):Dynamic;
	
	//soConnect
	function C(remoteId:String, maxUsers:Int, name:String):Bool;
	
	//soDisconnet
	function D(remoteId:String):Void;
	
	//soAction
	function A(remoteId:String, actionData:Array<Dynamic>):Void;
	
	//soLock
	function L(remoteId:String, stateId:String):Bool;
	
	//soUnlock
	function U(remoteId:String, stateId:String):Void;
}