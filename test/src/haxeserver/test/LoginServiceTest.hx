/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxe.Md5;
import haxelib.test.AsincTest;
import haxeserver.services.LoginService;

class LoginServiceTest extends AsincTest
{

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void 
	{
		new LoginService(onResult1).doLogin("lamer", Md5.encode("123"));
	}
	
	private function onResult1(result:Bool):Void
	{
		assertFalse(result);
		new LoginService(onResult2).doLogin("admin", Md5.encode("000"));
	}
	
	private function onResult2(result:Bool):Void
	{
		assertFalse(result);
		new LoginService(onResult3).doLogin("admin", Md5.encode("123"));
	}
	
	private function onResult3(result:Bool):Void
	{
		assertTrue(result);
		dispatchComplete();
	}
	
}