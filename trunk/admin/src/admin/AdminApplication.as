package admin
{
	import admin.commands.StartAppCommand;
	import flash.Boot;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.Lib;
	import haxeserver.RemoteConnection;
	import mx.core.Application;

	/**
	 * ...
	 * @author canab
	 */
	public class AdminApplication
	{
		static private var _instance:AdminApplication
		
		static public function get instance():AdminApplication
		{ 
			if (!_instance)
				_instance = new AdminApplication();
				
			return _instance;
		}
		
		private var _root:Main;
		private var _connection:RemoteConnection;
		private var _currentScreen:DisplayObject;
		
		public function initialize(main:Main):void 
		{
			_root = main;
			_connection = new RemoteConnection();
			new Boot();
			Lib.current = new MovieClip();
			new StartAppCommand().execute();
		}
		
		public function changeScreen(screen:DisplayObject):void 
		{
			if (_currentScreen)
				_root.removeChild(_currentScreen);
				
			_currentScreen = screen;
			
			if (_currentScreen)
				_root.addChild(_currentScreen);
		}
		
		public function get connection():RemoteConnection { return _connection; }
	}

}