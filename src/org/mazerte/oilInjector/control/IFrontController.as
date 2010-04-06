package org.mazerte.oilInjector.control
{
	import flash.events.IEventDispatcher;

	public interface IFrontController
	{
		function addAction( commandName : String, commandRef : Class, useWeakReference : Boolean = true ) : void;
		function removeAction( commandName : String ) : void;
	}
}