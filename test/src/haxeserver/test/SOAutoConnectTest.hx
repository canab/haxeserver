/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxe.Md5;
import haxelib.common.utils.ArrayUtil;
import haxelib.test.AsincTest;
import haxeserver.services.LoginService;
import haxeserver.services.SOService;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;

class SOAutoConnectTest extends AsincTest
{
	private var remoteId:String;

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void 
	{
		remoteId = "AutoConnect" + Main.instance.connection1.userId + "_" + tryNum;
		
		var service:SOService = new SOService(onConnect1);
		service.connection = Main.instance.connection1;
		service.connectToFreeSO(remoteId, 2);
	}
	
	private function onConnect1(result:String):Void
	{
		assertEquals(result, remoteId + "|1");
		
		var service:SOService = new SOService(onConnect2);
		service.connection = Main.instance.connection2;
		service.connectToFreeSO(remoteId, 2);
	}
	
	private function onConnect2(result:String):Void
	{
		assertEquals(result, remoteId + "|1");
		
		var service:SOService = new SOService(onConnect3);
		service.connection = Main.instance.connection3;
		service.connectToFreeSO(remoteId, 2);
	}
	
	private function onConnect3(result:String):Void
	{
		assertEquals(result, remoteId + "|2");
		dispatchComplete();
	}
}