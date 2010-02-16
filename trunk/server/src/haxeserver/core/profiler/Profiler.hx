/**
 * ...
 * @author canab
 */

package haxeserver.core.profiler;

class Profiler 
{
	public var items (default, null):Hash<ProfilerItem>;

	public function new() 
	{
		items = new Hash<ProfilerItem>();
	}
	
	public function addCall(id:String, time:Float):Void 
	{
		var item:ProfilerItem = items.get(id);
		if (item == null)
		{
			item = new ProfilerItem();
			items.set(id, item);
		}
		item.addCall(time);
	}
	
	public function clear():Void 
	{
		items = new Hash<ProfilerItem>();
	}
	
}