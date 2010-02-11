package admin
{
	import admin.login.Login;
	import flash.Boot;
	import flash.display.MovieClip;
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
		
		public function get connection():RemoteConnection { return _connection; }
		
		private var _root:Main;
		private var _haxeRoot:MovieClip = new MovieClip();
		private var _connection:RemoteConnection = new RemoteConnection();
		
		public function initialize(main:Main):void 
		{
			new Boot(_haxeRoot); // initialize haxe swc
			_root = main;
			_root.addChild(new Login());
		}
		
		public function get root():Main { return _root; }
	}

}