package haxelib.common.events {
	import haxelib.common.utils.ArrayUtil;
	import flash.Boot;
	public class EventSender {
		public function EventSender(sender : * = null) : void { if( !flash.Boot.skip_constructor ) {
			this.sender = sender;
			this.listeners = new Array();
		}}
		
		protected var listeners : Array;
		protected var sender : *;
		public function addListener(listener : Function) : void {
			if(this.hasListener(listener)) throw "List already contains such listener";
			else this.listeners.push(listener);
		}
		
		public function removeListener(listener : Function) : void {
			if(this.hasListener(listener)) this.listeners.remove(listener);
			else throw "List doesn't contains such listener";
		}
		
		public function sendEvent() : void {
			var handlers : Array = this.listeners.slice(0);
			{
				var _g : int = 0;
				while(_g < handlers.length) {
					var handler : Function = handlers[_g];
					++_g;
					handler(this.sender);
				}
			}
		}
		
		public function hasListener(listener : Function) : Boolean {
			return haxelib.common.utils.ArrayUtil.indexOf(this.listeners,listener) >= 0;
		}
		
	}
}
