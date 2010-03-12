package fpserver;

import haxe.io.Bytes;


typedef Client = {
	var host : String;
	var socket : neko.net.Socket;
}

/**
	Flash-policy-server.
	http://www.adobe.com/devnet/flashplayer/articles/socket_policy_files.html
*/
class Main extends neko.net.ThreadServer<Client,String> {
	
	static var policyFile : String;
	
	static function main() {
		
		var args = neko.Sys.args();
		if( args[0] == null || args[1]== null ) {
			neko.Lib.println( "Usage: neko fpserver.n [host] [port] [file]" );
			neko.Lib.println( "Aborted." );
			return;
		}
		var host = args[0];
		var port = Std.parseInt( args[1] );
		var filepath = args[2];
		
		policyFile = null;
		try {
			policyFile = neko.io.File.getContent( filepath );
		} catch( e : Dynamic ) {
			neko.Lib.println( "Cannot find policy find: " + filepath );
			return;
		}
		
		var r : EReg = ~/cross-domain-policy/;
		if( !r.match( policyFile ) ) {
			neko.Lib.println( "Invalid policy file: " + filepath );
			return;
		}
		
		var server = new Main();
		neko.Lib.println( "Starting flash-policy server ..." );
		server.run( host, port );
	}
	
	
	override function clientConnected( s : neko.net.Socket ) : Client {
		var host = s.peer().host.toString();
		neko.Lib.println( "Client connected: " + host );
		return { host:host, socket:s };
	}

	override function clientDisconnected( c : Client ) {
		neko.Lib.println( "Client disconnected: " + c.host );
	}

	override function readClientMessage( c : Client, buf : Bytes, pos : Int, len : Int ) {
		var complete = false;
		var cpos = pos;
		while( cpos < ( pos + len ) && !complete ) {
			complete = ( buf.get( cpos ) == 0 );
			cpos++;
		}
		if( !complete ) return null;
		var msg = buf.readString( pos, cpos - pos );
		return { msg : msg, bytes : cpos-pos };
	}

	override function clientMessage( c : Client, msg : String ) {
		var ereg = ~/policy-file-request/;
		if( !ereg.match( msg ) ) {
			c.socket.write( "FuckYou" );
			c.socket.close();
		}
		c.socket.write( policyFile );
		c.socket.output.writeByte( 0 );
		neko.Lib.println( "Sending policy to: " + c.host );
		//c.socket.close();
	}
	
}
