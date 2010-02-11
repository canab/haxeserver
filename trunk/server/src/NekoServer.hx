
import haxeserver.core.Application;
import neko.net.ThreadRemotingServer;
import haxe.remoting.SocketConnection;
import haxe.remoting.Context;

class NekoServer extends ThreadRemotingServer
{
	public static function main()
	{
		Application.createInstance();
		var server = new NekoServer();
		Application.instance.logger.trace("Start NekoServer");
		server.run("localhost", 8080);
	}

	override function initClientApi(connection:SocketConnection, context:Context)
	{
		Application.instance.addConnection(connection, context);
	}

	override function clientDisconnected(connection:SocketConnection)
	{
		Application.instance.removeConnection(connection);
	}
}