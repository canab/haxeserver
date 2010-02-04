/**
 * ...
 * @author Canab
 */

package test;
import flash.display.ActionScriptVersion;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import haxelib.common.commands.ICommand;
import haxeserver.RemoteClient;
import haxeserver.RemoteConnection;
import haxeserver.RemoteObject;

class ItemData
{
	public var userId:Int;
	public var id:Int;
	public var x:Int;
	public var y:Int;
	public var color:Int;
	
	public function new()
	{
	}
	
	public function getStateId():String
	{
		return "item|" + userId + "|" + id;
	}
}

class VisualTest extends RemoteClient
{
	static public var RADIUS:Int = 10;
	
	static private var REMOTE_ID:String = '00';
	static private var MAX_ITEMS:Int = 50;
	
	private var content:Sprite;
	private var connection:RemoteConnection;
	private var remote:RemoteObject;
	
	private var items:List<ItemSprite>;
	private var myItems:List<ItemData>;
	private var myItemId:Int;
	private var color:Int;
	
	public function new(connection:RemoteConnection, content:Sprite) 
	{
		super();
		this.connection = connection;
		this.content = content;
		
		connection.registerClass(ItemData);
		
		myItemId = 0;
		items = new List<ItemSprite>();
		myItems = new List<ItemData>();
		color = Std.int(Math.random() * 0xAAAAAA);
		initialize();
	}
	
	private function initialize():Void
	{
		remote = connection.getRemoteObject(REMOTE_ID);
		remote.connect(this);
	}
	
	override public function onReady():Void
	{
		content.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		//moveItems();
//content.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		if (myItems.length < MAX_ITEMS)
		{
			var data:ItemData = new ItemData();
			data.userId = remote.userId;
			data.x = Std.int(Math.random() * 640);
			data.y = Std.int(Math.random() * 480);
			data.color = color;
			data.id = myItemId++;
			
			myItems.add(data);
			remote.createState(data.getStateId(), data, true);
		}
		else
		{
			var data:ItemData = myItems.first();
			myItems.remove(data);
			remote.removeState(data.getStateId());
		}
	}
	
	private function moveItems():Void
	{
		for (myData in myItems)
		{
			var item:ItemSprite = getItem(myData.getStateId());
			if (item != null)
			{
				var x:Int = Std.int(item.x + item.vx);
				var y:Int = Std.int(item.y + item.vy);
				if (item.vx < 0 && x < 0 || item.vx > 0 && x > 640)
					item.vx *= -1;
				if (item.vy < 0 && y < 0 || item.vy > 0 && y > 480)
					item.vy *= -1;
				
				remote.sendState('rMove', item.data.getStateId(), { x:x, y:y } );
			}
		}
	}
	
	public function rMove(stateId:String, state:ItemData):Void 
	{
		var item:ItemSprite = getItem(stateId);
		item.x = state.x;
		item.y = state.y;
	}
	
	override public function onStateCreated(stateId:String, state:Dynamic):Void
	{
		var item:ItemSprite = new ItemSprite(state);
		item.addEventListener(MouseEvent.CLICK, onClick);
		items.add(item);
		content.addChild(item);
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		var item:ItemSprite = e.target;
		remote.lockState('rLock', item.data.getStateId(), { color: color } );
	}
	
	public function rLock(stateId:String, state:ItemData):Void 
	{
		if (state != null)
		{
			var item:ItemSprite = getItem(stateId);
			item.setColor(state.color);
			item.alpha -= 0.1;
		}
	}
	
	override public function onUserConnect(userId:Int):Void
	{
		trace("so user connected " + userId);
	}
	
	override public function onUserDisconnect(userId:Int):Void
	{
		trace("so user disconnected " + userId);
	}
	
	private function removeItem(item:ItemSprite):Void
	{
		content.removeChild(item);
		items.remove(item);
	}
	
	override public function onStateRemoved(stateId:String, state:Dynamic):Void
	{
		var item:ItemSprite = getItem(stateId);
		removeItem(item);
	}
	
	private function getItem(stateId:String):ItemSprite
	{
		for (item in items)
		{
			if (item.data.getStateId() == stateId)
				return item;
		}
		return null;
	}
	
	override public function onCommand(command:ICommand):Void
	{
		trace("so command " + command);
	}
}

class ItemSprite extends Sprite
{
	public var data:ItemData;
	public var vx:Float;
	public var vy:Float;
	
	public function new(data:ItemData)
	{
		super();
		this.data = data;
		repaint();
		this.x = data.x;
		this.y = data.y;
		this.cacheAsBitmap = true;
		
		var angle:Float = Math.random() * 2 * Math.PI;
		this.vx = 2 * Math.cos(angle);
		this.vy = 2 * Math.sin(angle);
	}
	
	public function setColor(color:Int):Void 
	{
		data.color = color;
		repaint();
	}
	
	public function repaint():Void 
	{
		this.graphics.clear();
		this.graphics.beginFill(data.color);
		this.graphics.drawCircle(0, 0, VisualTest.RADIUS);
		this.graphics.endFill();
	}
}
