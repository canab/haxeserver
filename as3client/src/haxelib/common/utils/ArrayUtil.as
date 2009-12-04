package haxelib.common.utils {
	public class ArrayUtil {
		public function ArrayUtil() : void {
			null;
		}
		
		static public function indexOf(array : Array,item : *) : int {
			{
				var _g1 : int = 0, _g : int = array.length;
				while(_g1 < _g) {
					var i : int = _g1++;
					if(array[i] == item) return i;
				}
			}
			return -1;
		}
		
	}
}
