/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;
import haxeserver.test.data.ItemData;

class MyClient extends RemoteClient
{
	private var test:SORestoreTest;
	private var remote:RemoteObject;
	
	public function new(test:SORestoreTest, remote:RemoteObject):Void 
	{
		super();
		this.test = test;
		this.remote = remote;
	}
	
	override public function onReady():Void 
	{
		remote.createState('i1', new ItemData());
		remote.createState('i2', new ItemData());
		remote.call('doChange');
	}
	
	public function doChange():Void 
	{
		remote.removeState('i1');
		remote.changeState('i2', { x: -50, y: -100, id: -1 } );
		remote.call('doCheck');
	}
	
	public function doCheck():Void 
	{
		test.connectOtherObject();
	}
}

class OtherClient extends RemoteClient
{
	private var test:SORestoreTest;
	private var remote:RemoteObject;
	
	public function new(test:SORestoreTest, remote:RemoteObject):Void 
	{
		super();
		this.test = test;
		this.remote = remote;
	}
	
	override public function onReady():Void 
	{
		test.checkStates();
	}
}

class SORestoreTest extends AsincTest
{
	private var myRemote:RemoteObject;
	private var otherRemote:RemoteObject;

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void
	{
		myRemote = new RemoteObject(Main.instance.remoteId);
		myRemote.connect(Main.instance.connection1, new MyClient(this, myRemote));
	}
	
	override public function dispose():Void 
	{
		myRemote.disconnect();
		otherRemote.disconnect();
	}
	
	public function connectOtherObject():Void 
	{
		otherRemote = new RemoteObject(Main.instance.remoteId);
		otherRemote.connect(Main.instance.connection2, new OtherClient(this, otherRemote));
	}
	
	public function checkStates():Void 
	{
		assertTrue(otherRemote.users.length == 2);
		assertTrue(otherRemote.states.get('i1') == null);
		
		var item:ItemData = cast(otherRemote.states.get('i2'), ItemData);
		assertTrue(item.id == -1);
		assertTrue(item.x == -50);
		assertTrue(item.y == -100);
		
		dispatchComplete();
	}
	
}