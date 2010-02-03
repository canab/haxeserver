/**
 * ...
 * @author canab
 */

package test;
import haxeserver.RemoteClient;
import haxeserver.RemoteConnection;
import haxeserver.services.ServiceBase;
import haxeserver.services.SOService;

class ServiceTest extends RemoteClient
{
	private var connection:RemoteConnection;
	
	public function new(connection:RemoteConnection)
	{
		super();
		
		this.connection = connection;
		ServiceBase.defaultConnection = connection;
		
		connection.createRemoteObject("qweqwe").connect(this);
		connection.createRemoteObject("asdasd").connect(this);
		
		new SOService(onResult).getSharedObjects();
		new SOService(onResult).getSharedObjects("qw");
		new SOService(onResult).getSharedObjects("a");
		new SOService(onResult).getSharedObjects("qww");
	}
	
	private function onResult(result:Dynamic):Void
	{
		trace("serviceResult: " + result);
	}
	
}