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
		
		protected function reset():void 
		{
			enabled = false;
			new AdminService(onResult).resetProfilerData();
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
				item.totalTime = String(itemData.shift()).substr(0, 6);
				item.minTime = String(itemData.shift()).substr(0, 6);
				item.maxTime = String(itemData.shift()).substr(0, 6);
				item.averageTime = String(item.totalTime / item.callCount).substr(0, 6);
				newItems.push(item);
			}
			items = new ArrayList(newItems);
		}
		
	}

}