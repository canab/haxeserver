package haxeserver.test;
import haxe.unit.TestCase;
import haxelib.test.AsincTest;
import haxeserver.so.IRemoteClient;
import haxeserver.so.RemoteObject;
import haxeserver.test.data.SampleCommand;

/**
 * ...
 * @author Canab
 */

class SOBigDataTest extends AsincTest, implements IRemoteClient
{
	private var remote:RemoteObject;
	private var data:String;
	
	public function new() 
	{
		super();
	}
	
	override public function initialize():Void
	{
		var remoteId:String = "BaseTest" + Main.instance.connection1.userId;
		remote = new RemoteObject(remoteId);
		remote.connect(Main.instance.connection1, this);
	}
	
	/* INTERFACE haxeserver.IRemoteClient */
	
	public function onReady():Void
	{
		data = createData(10000);
		var command:SampleCommand = new SampleCommand();
		command.text = data;
		remote.sendCommand(command);
	}
	
	private function createData(size:Int):String 
	{
		var data:String = "";
		
		for (i in 0...size) 
		{
			data += "0";
		}
		
		return data;
	}
	
	public function onCommand(command:Dynamic):Void
	{
		assertEquals(cast(command, SampleCommand).text, data);
		remote.disconnect();
		dispatchComplete();
	}
	
	/* INTERFACE haxeserver.so.IRemoteClient */
	
	public function onStateCreated(stateId:String, state:Dynamic):Void 
	{
	}
	
	public function onStateChanged(stateId:String, state:Dynamic):Void 
	{
	}
	
	public function onStateRemoved(stateId:String, state:Dynamic):Void 
	{
	}
	
	public function onUserConnect(userId:Int):Void 
	{
	}
	
	public function onUserDisconnect(userId:Int):Void 
	{
	}
	
}