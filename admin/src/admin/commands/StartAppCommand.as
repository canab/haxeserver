package admin.commands 
{
	import admin.abstract.CommandBase;
	import admin.login.Login;
	import common.utils.URLUtil;
	import haxeserver.services.ServiceBase;
	import mx.core.Application;
	
	/**
	 * ...
	 * @author canab
	 */
	public class StartAppCommand extends CommandBase
	{
		
		public function StartAppCommand() 
		{
		}
		
		override public function execute():void 
		{
			initializeConnection();
			app.root.addChild(new Login());			
		}
		
		private function initializeConnection():void
		{
			ServiceBase.defaultConnection = app.connection;
			
			var currentUrl:String = Application(Application.application).url;
			var serverName:String = URLUtil.getServerName(currentUrl);
			if (serverName.length == 0)
				serverName = 'localhost';
			app.connection.host = serverName;
			app.connection.port = 8080;
		}
		
	}

}