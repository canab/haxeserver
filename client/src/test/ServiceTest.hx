/**
 * ...
 * @author canab
 */

package test;
import haxe.Md5;
import haxeserver.RemoteClient;
import haxeserver.RemoteConnection;
import haxeserver.RemoteObject;
import haxeserver.services.AdminService;
import haxeserver.services.LoginService;
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
		
		//var remote:RemoteObject = connection.getRemoteObject("qweqwe");
		//remote.maxUsers = 2;
		//remote.connect(this);
		//connection.getRemoteObject("asdasd").connect(this);
		
		//new SOService(onResult).getSharedObjects();
		//new SOService(onResult).getSharedObjects("qw");
		//new SOService(onResult).getSharedObjects("a");
		//new SOService(onResult).getSharedObjects("qww");
		
		new SOService(onGetRemoteId).connectToFreeSO('FS', 2);
		new LoginService(onLogin).doLogin('admin', Md5.encode('123'));
		new AdminService(onGeneral).getGeneral();
		new AdminService(onProfiler).getProfilerData();
	}
	
	private function onProfiler(result:Dynamic):Void
	{
		trace('profiler:');
		trace(result);
	}
	
	private function onGeneral(result:Dynamic):Void
	{
		trace('general:');
		trace(result);
	}
	
	private function onLogin(result:Bool):Void 
	{
		trace('LoginService:' + result);
	}
	
	private function onGetRemoteId(remoteId:String):Void
	{
		trace(remoteId);
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