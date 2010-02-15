/**
 * ...
 * @author canab
 */

package haxeserver.core;
import haxe.xml.Fast;
import neko.io.File;

class ApplicationConfig
{
	public var host(default, null):String;
	public var port(default, null):Int;
	public var login(default, null):String;
	public var password(default, null):String;
	
	private var fileName:String;

	public function new(fileName:String) 
	{
		this.fileName = fileName;
		readConfig();
	}
	
	private function readConfig():Void
	{
		var content:String = File.getContent(fileName);
		var xml:Fast = new Fast(Xml.parse(content));
		var config = xml.node.config;
		
		host = config.node.host.innerData;
		port = Std.parseInt(config.node.port.innerData);
		login = config.node.login.innerData;
		password = config.node.password.innerData;
	}
	
}