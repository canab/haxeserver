package test {
	public class ItemData {
		public function ItemData() : void {
			null;
		}
		
		public var userId : int;
		public var id : int;
		public var x : int;
		public var y : int;
		public var color : int;
		public function getStateId() : String {
			return "item|" + this.userId + "|" + this.id;
		}
		
	}
}
