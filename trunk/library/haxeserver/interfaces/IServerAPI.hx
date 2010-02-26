package haxeserver.interfaces;

interface IServerAPI
{
	//callService
	function S(className:String, func:String, args:Array<Dynamic>):Dynamic;
	
	//soConnect
	function C(remoteId:String, maxUsers:Int):Void;
	
	//soDisconnet
	function D(remoteId:String):Void;
	
	//soAction
	function A(remoteId:String, actionData:Array<Dynamic>):Void;
}