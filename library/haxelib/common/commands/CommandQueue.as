package common.commands
{
	import common.events.EventSender;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Canab
	 */
	public class CommandQueue implements ICancelableCommand
	{
		private var _completeEvent:EventSender = new EventSender(this);
		private var _commands:Array = [];
		private var _currentCommand:IAsincCommand;
		private var _completed:Boolean = false;
		private var _started:Boolean = false;
		private var _canceled:Boolean = false;
		
		public function CommandQueue()
		{
			super();
		}
		
		public function add(command:IAsincCommand):void
		{
			_commands.push(command);
		}
		
		public function execute():void
		{
			_started = true;
			executeCommand();
		}
		
		private function executeCommand():void
		{
			_currentCommand = _commands.shift() as IAsincCommand;
			_currentCommand.completeEvent.addListener(onCommandComplete);
			_currentCommand.execute();
		}
		
		private function onCommandComplete(sender:IAsincCommand):void 
		{
			clearCurrentCommand();
			if (_commands.length > 0)
				executeCommand();
			else
				complete();
		}
		
		private function complete():void
		{
			_started = false;
			_completed = true;
			_completeEvent.sendEvent();
		}
		
		public function cancel():void
		{
			_started = false;
			_canceled = true;

			if (_currentCommand is ICancelableCommand)
				ICancelableCommand(_currentCommand).cancel();
		}
		
		private function clearCurrentCommand():void 
		{
			_currentCommand.completeEvent.removeListener(onCommandComplete);
			_currentCommand = null;
		}
		
		public function get completeEvent():EventSender { return _completeEvent; }
		
		public function get commands():Array { return _commands; }
		
		public function get started():Boolean { return _started; }
		public function get completed():Boolean { return _completed; }
		public function get canceled():Boolean { return _canceled; }
		
	}
	
}