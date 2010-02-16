/**
 * ...
 * @author Canab
 */

package haxeserver.core;
import haxe.PosInfos;
import neko.FileSystem;
import neko.io.File;
import neko.io.FileOutput;
import neko.io.Path;

class Logger 
{
	private var foutput:FileOutput;
	private var fileName:String;
	private var maxSize:Int;
	private var currentSize:Int;

	public function new(fileName:String, maxSize:Int)
	{
		this.fileName = fileName;
		this.maxSize = maxSize;
		openOutput();
	}
	
	private function openOutput():Void
	{
		foutput = File.append(fileName, false);
		currentSize = FileSystem.stat(fileName).size;
	}
	
	public function info(text:String, ?posInfos:PosInfos):Void 
	{
		writeMessage('INFO', text, posInfos);
	}
	
	public function error(text:String, ?posInfos:PosInfos):Void 
	{
		writeMessage('ERROR', text, posInfos);
	}
	
	private function writeMessage(type:String, message:String, info:PosInfos):Void 
	{
		var date:String = Date.now().toString();
		var sender:String = info.className.substr(info.className.lastIndexOf(".") + 1);
		var fullMessage:String = date + "\t[" + sender + "]\t" + type + "\t" + message; 
		
		currentSize += fullMessage.length;
		if (currentSize >= maxSize)
			createArchive();
		
		foutput.writeString(fullMessage + "\n");
		foutput.flush();
		neko.Lib.println("[" + sender + "]\t" + message);
	}
	
	private function createArchive():Void
	{
		foutput.close();
		currentSize = 0;
		
		var archFileName:String = getArchFileName();
		trace(archFileName);
		FileSystem.rename(fileName, archFileName);
		
		foutput = File.write(fileName, false);
	}
	
	private function getArchFileName():String
	{
		var newName:String = Path.withoutExtension(fileName)
			+ "_" + Date.now().toString()
			+ "." + Path.extension(fileName);
		newName = (~/:/g).replace(newName, "-");
		newName = (~/ /g).replace(newName, "_");
		
		var result:String = newName;
		var i:Int = 0;
		while (FileSystem.exists(result))
		{
			result = Path.withoutExtension(newName)
				+ "(" + (++i) + ")"
				+ "." + Path.extension(newName);
		}
		
		return result;
	}
	
}