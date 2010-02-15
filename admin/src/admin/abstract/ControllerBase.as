package admin.abstract
{
	import admin.AdminApplication;
	import common.events.EventManager;
	import common.events.EventSender;
	/**
	 * ...
	 * @author canab
	 */
	public class ControllerBase
	{
		private var _eventManager:EventManager;
		
		public function ControllerBase() 
		{
		}
		
		public function initialize():void 
		{
		}
		
		public function dispose():void 
		{
			if (_eventManager)
				_eventManager.clearEvents();
		}
		
		protected function get app():AdminApplication
		{
			return AdminApplication.instance;
		}
		
		protected function registerEvent(event:EventSender, handler:Function):void 
		{
			if (!_eventManager)
				_eventManager = new EventManager();
			_eventManager.registerEvent(event, handler);
		}
		
		protected function unregisterEvent(event:EventSender, handler:Function):void 
		{
			if (_eventManager)
				_eventManager.unregisterEvent(event, handler);
		}
		
		protected function clearEvents():void 
		{
			if (_eventManager)
				_eventManager.clearEvents();
		}
	}

} 