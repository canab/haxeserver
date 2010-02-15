package admin.abstract
{
	import common.commands.ICancelableCommand;
	import common.events.EventSender;
	
	/**
	 * ...
	 * @author Canab
	 */
	public class CommandBase extends ControllerBase implements ICancelableCommand
	{
		private var _completeEvent:EventSender = new EventSender(this);
		
		public function CommandBase() 
		{
		}
		
		/* INTERFACE common.commands.ICancelableCommand */
		
		public function execute():void
		{
		}
		
		public function cancel():void
		{
		}
		
		protected function dispathComplete():void 
		{
			_completeEvent.sendEvent();
		}
		
		public function get completeEvent():EventSender
		{
			return _completeEvent;
		}
	}

}