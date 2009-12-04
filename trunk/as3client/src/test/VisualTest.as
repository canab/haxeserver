package test {
	import haxeserver.RemoteObject;
	import haxelib.common.commands.ICommand;
	import haxeserver.RemoteConnection;
	import test.ItemData;
	import test.ItemSprite;
	import haxe.Log;
	import flash.display.Sprite;
	import flash.events.Event;
	import haxeserver.RemoteClient;
	import flash.Boot;
	public class VisualTest extends haxeserver.RemoteClient {
		public function VisualTest(connection : haxeserver.RemoteConnection = null,content : flash.display.Sprite = null) : void { if( !flash.Boot.skip_constructor ) {
			super();
			this.connection = connection;
			this.content = content;
			connection.registerClass(test.ItemData);
			this.myItemId = 0;
			this.items = new List();
			this.myItems = new List();
			this.color = Std._int(Math.random() * 11184810);
			this.initialize();
		}}
		
		protected var content : flash.display.Sprite;
		protected var connection : haxeserver.RemoteConnection;
		protected var remote : haxeserver.RemoteObject;
		protected var items : List;
		protected var myItems : List;
		protected var myItemId : int;
		protected var color : int;
		protected function initialize() : void {
			this.remote = this.connection.createRemoteObject(REMOTE_ID);
			this.remote.connect(this);
		}
		
		public override function onReady() : void {
			this.content.addEventListener(flash.events.Event.ENTER_FRAME,this.onEnterFrame);
		}
		
		protected function onEnterFrame(e : flash.events.Event) : void {
			this.moveItems();
			if(this.myItems.length < MAX_ITEMS) {
				var data : test.ItemData = new test.ItemData();
				data.userId = this.remote.getUserId();
				data.x = Std._int(Math.random() * 640);
				data.y = Std._int(Math.random() * 480);
				data.color = this.color;
				data.id = this.myItemId++;
				this.myItems.add(data);
				this.remote.createState(data.getStateId(),data,true);
			}
			else null;
		}
		
		protected function moveItems() : void {
			{ var $it : * = this.myItems.iterator();
			while( $it.hasNext() ) { var myData : test.ItemData = $it.next();
			{
				var item : test.ItemSprite = this.getItem(myData.getStateId());
				if(item != null) {
					var x : int = Std._int(item.x + item.vx);
					var y : int = Std._int(item.y + item.vy);
					if(item.vx < 0 && x < 0 || item.vx > 0 && x > 640) item.vx *= -1;
					if(item.vy < 0 && y < 0 || item.vy > 0 && y > 480) item.vy *= -1;
					this.remote.sendState("rMove",item.data.getStateId(),{ x : x, y : y});
				}
			}
			}}
		}
		
		public function rMove(stateId : String,state : test.ItemData) : void {
			var item : test.ItemSprite = this.getItem(stateId);
			item.x = state.x;
			item.y = state.y;
		}
		
		public override function onStateCreated(stateId : String,state : *) : void {
			var item : test.ItemSprite = new test.ItemSprite(state);
			this.items.add(item);
			this.content.addChild(item);
		}
		
		public override function onUserConnect(userId : int) : void {
			haxe.Log.trace("so user connected " + userId,{ fileName : "VisualTest.hx", lineNumber : 155, className : "test.VisualTest", methodName : "onUserConnect"});
		}
		
		public override function onUserDisconnect(userId : int) : void {
			haxe.Log.trace("so user disconnected " + userId,{ fileName : "VisualTest.hx", lineNumber : 160, className : "test.VisualTest", methodName : "onUserDisconnect"});
		}
		
		protected function removeItem(item : test.ItemSprite) : void {
			this.content.removeChild(item);
			this.items.remove(item);
		}
		
		public override function onStateRemoved(stateId : String,state : *) : void {
			var item : test.ItemSprite = this.getItem(stateId);
			this.removeItem(item);
		}
		
		protected function getItem(stateId : String) : test.ItemSprite {
			{ var $it : * = this.items.iterator();
			while( $it.hasNext() ) { var item : test.ItemSprite = $it.next();
			{
				if(item.data.getStateId() == stateId) return item;
			}
			}}
			return null;
		}
		
		public override function onCommand(command : haxelib.common.commands.ICommand) : void {
			haxe.Log.trace("so command " + command,{ fileName : "VisualTest.hx", lineNumber : 187, className : "test.VisualTest", methodName : "onCommand"});
		}
		
		static protected var REMOTE_ID : String = "00";
		static protected var MAX_ITEMS : int = 5;
	}
}
