package admin.general 
{
	import haxeserver.services.AdminService;
	import mx.containers.Canvas;
	
	/**
	 * ...
	 * @author canab
	 */
	public class GeneralViewBase extends Canvas
	{
		[Bindable] public var usersCount:int;
		[Bindable] public var soCount:int;
		
		public function GeneralViewBase() 
		{
		}
		
		protected function refresh():void 
		{
			enabled = false;
			new AdminService(onResult).getGeneral();
		}
		
		private function onResult(result:Object):void
		{
			usersCount = result.usersCount;
			soCount = result.soCount;
			enabled = true;
		}
	}

}