import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import haxeserver.RemoteConnection;
import test.VisualTest;

class ClientTest extends flash.display.MovieClip
{
	public static function main()
	{
		flash.Lib.current.addChild(new ClientTest());
	}
	
	private var connection:RemoteConnection;

	public function new()
	{
		super();
		if (this.stage != null)
			initialize();
		else
			this.addEventListener(Event.ADDED_TO_STAGE, initialize);
	}
	
	private function initialize(e:Event = null):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, initialize);
		stage.scaleMode = StageScaleMode.NO_SCALE;
		createConnection();
	}
	
	private function createConnection():Void
	{
		connection = new RemoteConnection();
		connection.host = "localhost";
		connection.port = 4040;
		connection.connectEvent.addListener(onConnect);
		connection.errorEvent.addListener(onError);
		connection.connect();
		trace("connecting to " + connection.host + ":" + connection.port + "...");
	}
	
	private function onError(sender:RemoteConnection):Void
	{
		trace(connection.errorMessage);
	}
	
	private function onConnect(sender:RemoteConnection):Void
	{
		trace("connected: id=" + connection.userId);
		new VisualTest(connection, this);
	}
}