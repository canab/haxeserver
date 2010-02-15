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
			ServiceBase.defaultConnection = app.connection;
			app.connection.host = CONFIG::host;
			app.connection.port = CONFIG::port;
			
			app.changeScreen(new Login());
		}
	}

}