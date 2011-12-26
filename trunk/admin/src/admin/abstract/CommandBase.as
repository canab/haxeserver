package admin.abstract
{
	import actionlib.common.commands.ICancelableCommand;
	import actionlib.common.events.EventSender;
	
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
			_completeEvent.dispatch();
		}
		
		public function get completeEvent():EventSender
		{
			return _completeEvent;
		}
	}

}