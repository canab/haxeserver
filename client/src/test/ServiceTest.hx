/**
 * ...
 * @author canab
 */

package test;
import haxeserver.RemoteClient;
import haxeserver.RemoteConnection;
import haxeserver.RemoteObject;
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
		
		var remote:RemoteObject = connection.getRemoteObject("qweqwe");
		remote.maxUsers = 2;
		remote.connect(this);
		//connection.getRemoteObject("asdasd").connect(this);
		
		//new SOService(onResult).getSharedObjects();
		//new SOService(onResult).getSharedObjects("qw");
		//new SOService(onResult).getSharedObjects("a");
		//new SOService(onResult).getSharedObjects("qww");
	}
	
	override public function onReady():Void
	{
		trace('ready');
	}
	
	override public function onSharedObjectFull():Void
	{
		trace('full');
	}
	
	private function onResult(result:Dynamic):Void
	{
		trace("serviceResult: " + result);
	}
	
}