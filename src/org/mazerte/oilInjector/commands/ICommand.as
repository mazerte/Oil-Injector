package org.mazerte.oilInjector.commands
{
	import flash.events.IEventDispatcher;

	[Event(name="complete", type="org.mazerte.oilInjector.commands.CommandEvent")]
	[Event(name="error", type="org.mazerte.oilInjector.commands.CommandEvent")]
	public interface ICommand extends IEventDispatcher
	{
		function execute():void;
		function clear():void;
	}
}