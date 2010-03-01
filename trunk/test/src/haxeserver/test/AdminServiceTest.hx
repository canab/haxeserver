/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.services.AdminService;

class AdminServiceTest extends AsincTest
{

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void 
	{
		new AdminService(onGeneral).getGeneral();
	}
	
	private function onGeneral(result:Dynamic):Void
	{
		assertTrue(result.soCount >= 0);
		assertTrue(result.usersCount >= 1);
		
		new AdminService(onProfiledData).getProfilerData();
	}
	
	private function onProfiledData(result:Dynamic):Void
	{
		dispatchComplete();
	}
	
}