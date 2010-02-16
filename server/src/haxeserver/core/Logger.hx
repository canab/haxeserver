/**
 * ...
 * @author Canab
 */

package haxeserver.core;
import haxe.PosInfos;
import haxe.Stack;
import neko.FileSystem;
import neko.io.File;
import neko.io.FileOutput;
import neko.io.Path;
import neko.vm.Mutex;

class Logger 
{
	private var foutput:FileOutput;
	private var fileName:String;
	private var maxSize:Int;
	private var currentSize:Int;
	private var mutex:Mutex;

	public function new(fileName:String, maxSize:Int)
	{
		this.fileName = fileName;
		this.maxSize = maxSize;
		mutex = new Mutex();
		openOutput();
	}
	
	private function openOutput():Void
	{
		foutput = File.append(fileName, false);
		currentSize = FileSystem.stat(fileName).size;
	}
	
	public function info(text:String, ?posInfos:PosInfos):Void 
	{
		var sender:String = posInfos.className.substr(posInfos.className.lastIndexOf(".") + 1);
		var message:String = "[" + sender + "]\t" + text;
		writeMessage(message);
	}
	
	public function exception(e:Dynamic, ?posInfos:PosInfos):Void 
	{
		var message:String = "\n[EXCEPTION]\t" + e + "\n";
		message += "\tcallstack:\n";
		for (stackItem in Stack.exceptionStack())
		{
			message += "\t";
			message += stackItem;
			message += "\n";
		}
		writeMessage(message);
	}
	
	private function writeMessage(message:String):Void
	{
		mutex.acquire();
		
		var date:String = Date.now().toString();
		var fullMessage:String = date + "\t" + message; 
		
		currentSize += fullMessage.length;
		if (currentSize >= maxSize)
			createArchive();
		
		foutput.writeString(fullMessage + "\n");
		foutput.flush();
		neko.Lib.println(message);
		
		mutex.release();
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