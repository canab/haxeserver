﻿package haxeserver.interfaces;

interface IClientAPI
{
	function setId(userId:Int):Void;
	
	//soConnect
	function C(remoteId:String, userId:Int):Void;
	
	//soDisconnet
	function D(remoteId:String, userId:Int):Void;
	
	// soRestore
	function R(remoteId:String, usersList:Array<Dynamic>, statesList:Array<Dynamic>):Void;
	
	// soAction
	function A(remoteId:String, actionData:Array<Dynamic>):Void;
}