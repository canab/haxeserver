package admin.general 
{
	import mx.containers.Canvas;
	import mx.controls.Button;
	
	/**
	 * ...
	 * @author canab
	 */
	public class GeneralViewBase extends Canvas
	{
		[Bindable] public var refreshButton:Button;
		
		public function GeneralViewBase() 
		{
		}
		
		protected function onRefresh():void 
		{
			enabled = false;
		}
	}

}