/**
 * ...
 * @author canab
 */

package haxeserver.services;
import haxe.Md5;

class LoginService extends ServiceBase
{
	public function new() 
	{
		super();
	}
	
	public function doLogin(login:String, md5Password:String):Bool
	{
		if (login == application.config.login && md5Password == Md5.encode(application.config.password))
		{
			currentUser.login = login;
			return true;
		}
		else
		{
			return false;
		}
	}
	
}