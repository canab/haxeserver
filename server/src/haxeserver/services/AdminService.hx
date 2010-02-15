/**
 * ...
 * @author canab
 */

package haxeserver.services;
import haxelib.common.utils.ArrayUtil;

class AdminService extends ServiceBase
{

	public function new() 
	{
		super();
	}
	
	public function getGeneral():Dynamic
	{
		var result:Dynamic = { };
		result.usersCount = ArrayUtil.getLength(application.users);
		result.soCount = ArrayUtil.getLength(application.sharedObjects);
		
		return result;
	}
	
}