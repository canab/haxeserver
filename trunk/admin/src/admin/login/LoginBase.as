package admin.login
{
	import common.utils.StringUtil;
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.controls.TextInput;
	
	/**
	 * ...
	 * @author canab
	 */
	public class LoginBase extends Canvas
	{
		[Bindable] public var loginInput:TextInput;
		[Bindable] public var passwordInput:TextInput;
		[Bindable] public var loginEnabled:Boolean;
		[Bindable] public var inputEnabled:Boolean = true;
		
		public function LoginBase() 
		{
		}
		
		protected function onCreationComplete():void 
		{
			refresh();
			loginInput.setFocus();
			
			CONFIG::autologin
			{
				loginInput.text = CONFIG::login;
				passwordInput.text = CONFIG::password;
				refresh();
				doLogin();
			}
			
		}
		
		protected function doLogin():void 
		{
			if (!loginEnabled)
				return;
			
			loginEnabled = false;
			inputEnabled = false;
			
			var command:LoginCommand = new LoginCommand(login, password);
			command.completeEvent.addListener(onLoginResult);
			command.execute();
		}
		
		private function onLoginResult(command:LoginCommand):void
		{
			loginEnabled = !command.success;
			inputEnabled = !command.success;
		}
		
		protected function refresh():void
		{
			loginEnabled = (login.length > 0 && password.length > 0);
		}
		
		protected function get login():String
		{
			return StringUtil.trim(loginInput.text);
		}
		
		protected function get password():String
		{
			return StringUtil.trim(passwordInput.text);
		}
	}

}