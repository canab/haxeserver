package haxelib.common.events;
import haxelib.common.utils.ArrayUtil;

class EventSender<T>
{
	private var listeners:Array<T->Void>;
	private var sender:T;
	
	public function new(sender:T)
	{
		this.sender = sender;
		this.listeners = new Array<T->Void>();
	}
	
	public function addListener(listener:T->Void)
	{
		if (hasListener(listener))
			throw "List already contains such listener";
		else
			listeners.push(listener);
	}
	
	public function removeListener(listener:T->Void)
	{
		if (hasListener(listener))
			listeners.remove(listener);
		else
			throw "List doesn't contains such listener";
	}
	
	public function sendEvent()
	{
		var handlers:Array<T->Void> = listeners.slice(0);
		for (handler in handlers)
		{
			handler(sender);
		}
	}

	public function hasListener(listener:T->Void):Bool
	{
		return ArrayUtil.indexOf(listeners, listener) >= 0;
	}
}
