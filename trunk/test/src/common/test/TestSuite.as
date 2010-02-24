package common.test 
{
	/**
	 * ...
	 * @author canab
	 */
	public class TestSuite
	{
		private var _tests:Array = [];
		
		public function TestSuite() 
		{
			
		}
		
		public function add(test:Test):void 
		{
			_tests.push(test);
			
		}
		
	}

}