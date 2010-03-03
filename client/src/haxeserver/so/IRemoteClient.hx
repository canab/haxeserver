/**
 * ...
 * @author Canab
 */

package haxeserver.so;

interface IRemoteClient 
{
	function onReady():Void;
	function onUserConnect(userId:Int):Void;
	function onUserDisconnect(userId:Int):Void;
	function onStateCreated(stateId:String, state:Dynamic):Void;
	function onStateChanged(stateId:String, state:Dynamic):Void;
	function onStateRemoved(stateId:String, state:Dynamic):Void;
	function onCommand(command:Dynamic):Void;
}