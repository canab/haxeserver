/**
 * ...
 * @author canab
 */

package haxeserver.services;
import haxeserver.core.Application;
import haxeserver.core.UserAdapter;

class ServiceBase 
{
	public var currentUser:UserAdapter;
	private var application:Application;
	
	public function new()
	{
		application = Application.instance;
	}
	
}