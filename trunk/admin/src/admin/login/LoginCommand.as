package admin.login 
{
	import admin.abstract.CommandBase;
	import admin.NavigatorView;
	import haxe.Md5;
	import haxeserver.RemoteConnection;
	import haxeserver.services.LoginService;
	import mx.controls.Alert;
	
	/**
	 * ...
	 * @author canab
	 */
	public class LoginCommand extends CommandBase
	{
		private var _login:String;
		private var _password:String;
		private var _success:Boolean = false;
		
		public function LoginCommand(login:String, password:String) 
		{
			_login = login;
			_password = password;
		}
		
		override public function execute():void 
		{
			app.connection.connectEvent.addListener(onConnect);
			app.connection.errorEvent.addListener(onError);
			app.connection.connect();
		}
		
		private function onConnect(sender:RemoteConnection):void
		{
			new LoginService(onLogin).doLogin(_login, Md5.encode(_password));
		}
		
		private function onLogin(result:Boolean):void 
		{
			_success = result;
			if (!_success)
			{
				app.connection.disconnect();
				Alert.show('Login error.');
			}
			else
			{
				app.changeScreen(new NavigatorView());
			}
			dispose();
			dispathComplete();
		}
		
		private function onError(sender:RemoteConnection):void
		{
			Alert.show(sender.errorMessage);
			dispose();
			dispathComplete();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			app.connection.connectEvent.removeListener(onConnect);
			app.connection.errorEvent.removeListener(onError);
		}
		
		public function get success():Boolean { return _success; }
	}

}