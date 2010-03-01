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
	
	public function add(test:Test, tryCount:Int = 1):Void 
	{
		test.tryCount = tryCount;
		tests.push(test);
	}
	
	public function run():Void 
	{
		index = 0;
		nextTest();
	}
	
	private function nextTest():Void
	{
		while (index < tests.length)
		{
			var test:Test = tests[index];
			
			if (Std.is(test, AsincTest))
			{
				var asincTest:AsincTest = cast(test, AsincTest);
				if (asincTest.tryNum == 0)
				{
					trace(Type.getClass(test));
					asincTest.completeEvent.addListener(onAsincTestComplete);
				}
				asincTest.initialize();
				break;
			}
			else
			{
				trace(Type.getClass(test));
				while (test.tryNum < test.tryCount)
				{
					test.tryNum++;
					test.initialize();
					test.dispose();
					if (!test.success)
					{
						succes = false;
						break;
					}
				}
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
		sender.dispose();
		if (!sender.success)
			succes = false;
		
		sender.tryNum++;
		if (sender.tryNum == sender.tryCount)
			index++;
			
		if (succes)
			nextTest();
	}
}