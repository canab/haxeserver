package haxeserver.customprotocol;
import neko.net.ThreadServer;
import neko.net.Socket;

class UnsizedRemotingServer extends ThreadServer<UnsizedSocketConnection,String> {

	var domains : Array<String>;
	var port : Int;

	public function new( ?domains ) {
		super();
		messageHeaderSize = 2;
		this.domains = domains;
	}

	public dynamic function initClientApi( cnx : haxe.remoting.SocketConnection, ctx : haxe.remoting.Context ) {
		throw "Not implemented";
	}

	public dynamic function onXml( cnx : haxe.remoting.SocketConnection, data : String ) {
		throw "Unhandled XML data '"+data+"'";
	}

	public dynamic function makePolicyFile() {
		var str = "<cross-domain-policy>";
		for( d in domains )
			str += '<allow-access-from domain="'+d+'" to-ports="'+port+'"/>';
		str += "</cross-domain-policy>";
		return str;
	}

	public override function run( host, port ) {
		this.port = port;
		super.run(host,port);
	}

	public override function clientConnected( s : neko.net.Socket ) {
		var ctx = new haxe.remoting.Context();
		var cnx = UnsizedSocketConnection.create(s,ctx);
		var me = this;
		cnx.setErrorHandler(function(e) {
			if( !Std.is(e,haxe.io.Eof) && !Std.is(e,haxe.io.Error) )
				me.logError(e);
			me.stopClient(s);
		});
		initClientApi(cnx,ctx);
		return cnx;
	}

	override function readClientMessage( cnx : UnsizedSocketConnection, buf : haxe.io.Bytes, pos : Int, len : Int ) {
		var msgLen = cnx.getProtocol().messageLength(buf.get(pos),buf.get(pos+1));
		if( msgLen == null ) {
			if( buf.get(pos) != 60 )
				throw "Invalid remoting message '"+buf.readString(pos,len)+"'";
			var p = pos;
			while( p < len ) {
				if( buf.get(p) == 0 )
					break;
				p++;
			}
			if( p == len )
				return null;
			p -= pos;
			return {
				msg : buf.readString(pos,p),
				bytes : p + 1,
			};
		}
		if( len < msgLen )
			return null;
		if( buf.get(pos + msgLen-1) != 0 )
			throw "Truncated message";
		return {
			msg : buf.readString(pos+2,msgLen-3),
			bytes : msgLen,
		};
	}

	public override function clientMessage( cnx : UnsizedSocketConnection, msg : String ) {
		try {
			if( msg.charCodeAt(0) == 60 ) {
				if( domains != null && msg == "<policy-file-request/>" )
					cnx.getProtocol().socket.write(makePolicyFile()+"\x00");
				else
					onXml(cnx,msg);
			} else
				cnx.processMessage(msg);
		} catch( e : Dynamic ) {
			if( !Std.is(e,haxe.io.Eof) && !Std.is(e,haxe.io.Error) )
				logError(e);
			stopClient(cnx.getProtocol().socket);
		}
	}

}
