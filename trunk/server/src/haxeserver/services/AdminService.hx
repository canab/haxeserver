/**
 * ...
 * @author canab
 */

package haxeserver.services;
import haxelib.common.utils.ArrayUtil;
import haxeserver.core.profiler.ProfilerItem;

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
	
	public function getProfilerData():Dynamic
	{
		var result:Dynamic = { };
		var items:Hash<ProfilerItem> = application.profiler.items;
		for (key in items.keys())
		{
			Reflect.setField(result, key, items.get(key).serialize());
		}
		return result;
	}
	
	public function resetProfilerData():Dynamic
	{
		application.profiler.clear();
		return getProfilerData();
	}
}