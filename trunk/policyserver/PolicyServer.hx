package ;

import neko.io.File;
import neko.net.Host;
import neko.net.Socket;
import neko.net.ServerLoop;
import haxe.io.Bytes;

typedef PolicyClientData = {
	id:Int,
	sock:Socket
}

class PolicyServer extends ServerLoop < PolicyClientData > {
	
	public static var DEFAULT_BUFSIZE = 64;
	
	private var policyfile:Bytes;
	private var host:String;
	private var port:Int;
	private var nclient:Int;
	
	static private var instance:PolicyServer;
	
	static public function main()
	{
		instance = new PolicyServer('localhost');
	}

	public function new(host:String, ?port:Int) {
		
		nclient = 0;
		this.port = (port != null?port:843);
		this.host = host;
		
		try {
			loadPolicyFile();
		}
		catch (e:Dynamic) {
			trace("problem loading policy file");
		}
		super(addClient);	
		listenCount = 100;
		trace("PolicyServer starting on " + this.host + " at port " + this.port);
		try {
			run(new Host(this.host), this.port);
		} 
		catch (e:Dynamic) {
			trace("Another server is running at port "+this.port+" on "+this.host);
		}
		
	}
	
	private function loadPolicyFile() {
		policyfile = Bytes.ofString(File.getContent("cross-domain.xml")+String.fromCharCode(0));
	}
	
	override public function processClientData( d : PolicyClientData, buf : haxe.io.Bytes, bufpos : Int, buflen : Int ) {
		if (StringTools.startsWith(buf.toString(),"<policy-file-request/>")) {
			clientWrite(d.sock, policyfile, 0, policyfile.length);
			trace("Policyfile to client " + d.id + " delivered at port "+this.port+" on "+this.host+"!");
			return buflen;
		}
		trace("Client " + d.id + " send unknown request");
		return 0;
	}
	
	
	override public function clientDisconnected( d : PolicyClientData ) {
		trace("Client "+d.id+" left");
	}
	
	private function addClient(s:Socket):PolicyClientData {
		nclient++;
		var client:PolicyClientData = { sock:s, id:nclient };
		trace("Client " + client.id + " joined");
		return client;
	}
	
}
