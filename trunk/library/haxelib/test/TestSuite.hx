/**
 * ...
 * @author canab
 */

package haxelib.test;
import haxelib.common.events.EventSender;

class TestSuite 
{
	public var completeEvent(default, null):EventSender<TestSuite>;
	public var succes(default, null):Bool;
	
	private var tests:Array<Test>;
	private var index:Int;

	public function new() 
	{
		completeEvent = new EventSender(this);
		tests = new Array<Test>();
		succes = true;
	}
	
	public function add(test:Test):Void 
	{
		tests.push(test);
	}
	
	public function run():Void 
	{
		index = 0;
		nextTest();
	}
	
	private function nextTest():Void
	{
		trace(index);
		while (index < tests.length)
		{
			var test:Test = tests[index];
			trace(Type.getClass(test));
			
			if (Std.is(test, AsincTest))
			{
				var asincTest:AsincTest = cast(test, AsincTest);
				asincTest.completeEvent.addListener(onAsincTestComplete);
				asincTest.initialize();
				break;
			}
			else
			{
				test.initialize();
				test.dispose();
				if (!test.success)
					succes = false;
				index++;
			}
		}
		if (index == tests.length)
		{
			completeEvent.sendEvent();
		}
	}
	
	private function onAsincTestComplete(sender:AsincTest):Void
	{
		if (!sender.success)
			succes = false;
		index++;
		nextTest();
	}
	
	
}