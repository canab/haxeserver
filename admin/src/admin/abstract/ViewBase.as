package admin.abstract 
{
	import common.comparing.NameRequirement;
	import common.utils.GraphUtil;
	import components.Sounds;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import admin.abstract.ControllerBase;
	/**
	 * ...
	 * @author canab
	 */
	public class ViewBase extends ControllerBase
	{
		static public var defaultClickSound:Class;
		
		private var _content:Sprite;
		
		public function ViewBase(content:Sprite) 
		{
			_content = content;
		}
		
		protected function setButtonAction(button:InteractiveObject, handler:Function,
			soundClass:Class = null, ...rest):void 
		{
			var clickHandler:Function = function(e:MouseEvent):void
			{
				handler.apply(this, rest);
			}
			
			var pressHandler:Function = function(e:MouseEvent):void
			{
				if (soundClass || defaultClickSound)
					Sounds.play(soundClass || defaultClickSound);
			}
			
			button.addEventListener(MouseEvent.MOUSE_DOWN, pressHandler);
			button.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		protected function setButtonText(button:SimpleButton, fieldName:String, value:*):void 
		{
			var fields:Array = GraphUtil.getAllButtonChildren(button, new NameRequirement(fieldName));
			for each (var field:TextField in fields)
			{
				field.text = String(value);
			}
		}
		
		protected function setButtonEnabled(button:InteractiveObject, enabled:Boolean):void 
		{
			GraphUtil.setBtnEnabled(button, enabled);
		}
		
		
		public function get content():Sprite { return _content; }
	}

}沭