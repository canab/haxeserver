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

class SOServiceTest extends AsincTest
{
	private var remote:RemoteObject;
	private var remoteId:String;

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void 
	{
		remoteId = "ServiceTest" + Main.instance.connection1.userId + "_" + tryNum;
		
		remote = new RemoteObject(remoteId);
		remote.connect(Main.instance.connection1, new RemoteClient());
		new SOService(onGetSharedObjects).getSharedObjects(remoteId);
	}
	
	private function onGetSharedObjects(result:Array<String>):Void
	{
		assertTrue(ArrayUtil.contains(result, remoteId));
		remote.disconnect();
		dispatchComplete();
	}
	
}