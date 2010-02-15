/**
 * ...
 * @author canab
 */

package haxeserver.services;

class LoginService extends ServiceBase
{
	public function new(onResult:Dynamic->Void = null, onError:Dynamic->Void = null) 
	{
		super(onResult, onError);
	}
	
	public function doLogin(login:String, md5Password:String):Void
	{
		doCall("doLogin", [login, md5Password]);
	}
}