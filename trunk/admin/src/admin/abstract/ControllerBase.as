package admin.abstract
{
	import common.events.EventManager;
	import common.events.EventSender;
	import admin.Application;
	import admin.ApplicationData;
	import admin.game.Game;
	import admin.MainWindow;
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
		
		protected function get application():Application
		{
			return Application.instance;
		}
		
		protected function get appData():ApplicationData
		{
			return Application.instance.appData;
		}
		
		protected function get mainWindow():MainWindow
		{
			return Application.instance.mainWindow;
		}
		
		protected function get appConfig():ApplicationConfig
		{
			return Application.instance.appConfig;
		}
		
		protected function get game():Game
		{
			return Application.instance.game;
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