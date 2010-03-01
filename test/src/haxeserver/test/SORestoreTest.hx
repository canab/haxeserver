/**
 * ...
 * @author canab
 */

package haxeserver.test;
import haxelib.test.AsincTest;
import haxeserver.so.RemoteClient;
import haxeserver.so.RemoteObject;
import haxeserver.test.data.ItemData;

private class MyClient extends RemoteClient
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

private class OtherClient extends RemoteClient
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
	private var remoteId:String;

	public function new() 
	{
		super();
	}
	
	override public function initialize():Void
	{
		remoteId = "RestoreTest" + Main.instance.connection1.userId;
		myRemote = new RemoteObject(remoteId);
		myRemote.connect(Main.instance.connection1, new MyClient(this, myRemote));
	}
	
	override public function dispose():Void 
	{
		myRemote.disconnect();
		otherRemote.disconnect();
	}
	
	public function connectOtherObject():Void 
	{
		otherRemote = new RemoteObject(remoteId);
		otherRemote.connect(Main.instance.connection2, new OtherClient(this, otherRemote));
	}
	
	public function checkStates():Void 
	{
		assertEquals(otherRemote.users.length, 2);
		assertEquals(otherRemote.states.get('i1'), null);
		
		var item:ItemData = cast(otherRemote.states.get('i2'), ItemData);
		assertEquals(item.id, -1);
		assertEquals(item.x, -50);
		assertEquals(item.y, -100);
		
		dispatchComplete();
	}
	
}