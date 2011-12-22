package haxeserver.customprotocol;
import haxe.io.Error;
import haxe.remoting.SocketProtocol;

#if (neko)
import neko.Sys;
#end

class UnsizedSocketProtocol extends SocketProtocol
{
	public static var MAXSTRINGSIZE : Int = 4091;
	
	private var isBlocking:Bool;
	
	public function new( sock, ctx ) {
		super(sock, ctx);
		isBlocking = false;
	}
	
	private function cutAndSendMessage(message : String) : Void
	{
		var ttSize = message.length;
		var lastMessage = false;
		while (!lastMessage)
		{
			lastMessage = (message.length <= UnsizedSocketProtocol.MAXSTRINGSIZE);
			//send the substr message
			
			var messagePart:String = message.substr(0, UnsizedSocketProtocol.MAXSTRINGSIZE)
				+ (lastMessage ? "0" : "1");
			
			sendMessage(messagePart);
			
			//save into message the remaining string
			message = message.substr(UnsizedSocketProtocol.MAXSTRINGSIZE, ttSize);
		}
	}
	
	override public function sendRequest( path : Array<String>, params : Array<Dynamic> )
	{
		var s = new haxe.Serializer();
		s.serialize(true);
		s.serialize(path);
		s.serialize(params);
		cutAndSendMessage(s.toString());
	}
	
	override public function sendAnswer( answer : Dynamic, ?isException : Bool)
	{
		var s = new haxe.Serializer();
		s.serialize(false);
		if( isException )
			s.serializeException(answer);
		else
			s.serialize(answer);
		cutAndSendMessage(s.toString());
	}
}