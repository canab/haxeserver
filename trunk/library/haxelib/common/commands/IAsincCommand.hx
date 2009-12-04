package haxelib.common.commands;

import haxelib.events.EventSender;
	
interface IAsincCommand implements IAsincCommand
{
	function get completeEvent():EventSender;
}
