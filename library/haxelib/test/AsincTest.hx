/**
 * ...
 * @author canab
 */

package haxelib.test;
import haxelib.common.events.EventSender;

class AsincTest extends Test
{
	public var completeEvent(default, null):EventSender<AsincTest>;

	public function new() 
	{
		super();
		completeEvent = new EventSender<AsincTest>(this);
	}
	
	private function dispatchComplete():Void 
	{
		completeEvent.sendEvent();
	}
	
}