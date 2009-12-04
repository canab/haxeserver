package common.commands
{
	import common.events.EventSender;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Canab
	 */
	public class CallFuntionCommand implements ICancelableCommand
	{
		private var _completeEvent:EventSender = new EventSender(this);
		
		private var _timer:Timer;
		private var _function:Function;
		private var _args:Array;
		private var _thisObject:Object;
		
		public function CallFuntionCommand(func:Function, delay:uint = 100, thisObject:Object=null, args:Array=null)
		{
			_function = func;
			_thisObject = thisObject;
			_args = args;
			
			_timer = new Timer(delay, 1);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public function execute():void
		{
			_timer.start();
			_completeEvent.sendEvent();
		}
		
		public function cancel():void
		{
			_timer.stop();
		}
		
		private function onTimer(e:TimerEvent):void
		{
			if(!_args && !_thisObject)
				_function();
			else
				_function.apply(_thisObject, _args);
		}
		
		public function get completeEvent():EventSender { return _completeEvent; }
	}
	
}

