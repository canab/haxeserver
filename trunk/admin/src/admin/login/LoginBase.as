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
		}
		
		protected function doLogin():void 
		{
			if (loginEnabled)
			{
				loginEnabled = false;
				inputEnabled = false;
			}
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