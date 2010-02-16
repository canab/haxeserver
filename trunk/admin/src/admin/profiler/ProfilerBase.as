package admin.profiler 
{
	import haxeserver.services.AdminService;
	import mx.collections.ArrayList;
	import mx.containers.Canvas;
	
	/**
	 * ...
	 * @author canab
	 */
	public class ProfilerBase extends Canvas
	{
		[Bindable] public var items:ArrayList;
		
		public function ProfilerBase() 
		{
		}
		
		protected function refresh():void 
		{
			enabled = false;
			new AdminService(onResult).getProfilerData();
		}
		
		private function onResult(result:Object):void
		{
			enabled = true;
			var newItems:Array = [];
			for (var key:String in result)
			{
				var itemData:Array = result[key];
				var item:Object = {};
				item.id = key;
				item.callCount = itemData.shift();
				item.totalTime = itemData.shift();
				item.minTime = itemData.shift();
				item.maxTime = itemData.shift();
				item.averageTime = item.totalTime / item.callCount;
				newItems.push(item);
			}
			items = new ArrayList(newItems);
		}
		
	}

}