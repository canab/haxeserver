/**
 * ...
 * @author canab
 */

package haxeserver.core.profiler;
import neko.vm.Mutex;

class ProfilerItem 
{
	private var callCount:Int;
	private var totalTime:Float;
	private var minTime:Float;
	private var maxTime:Float;
	
	private var mutex:Mutex;

	public function new() 
	{
		callCount = 0;
		totalTime = 0;
		minTime = 0;
		maxTime = 0;
		
		mutex = new Mutex();
	}
	
	public function serialize():Array<Dynamic>
	{
		mutex.acquire();
		var result:Array<Dynamic> = [callCount, totalTime, minTime, maxTime];
		mutex.release();
		return result;
	}
	
	
	public function addCall(time:Float):Void 
	{
		mutex.acquire();
		
		callCount++;
		totalTime += time;
		
		if (time < minTime || minTime == 0)
			minTime = time;
		if (time > maxTime)
			maxTime = time;
			
		mutex.release();
	}
	
}