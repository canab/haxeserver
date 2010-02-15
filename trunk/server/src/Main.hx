
import haxeserver.core.Application;
import haxeserver.services.AdminService;
import haxeserver.services.LoginService;
import haxeserver.services.SOService;

class Main
{
	public static function main()
	{
		SOService;
		LoginService;
		AdminService;
		
		Application.createInstance();
	}
}