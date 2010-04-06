package org.mazerte.oilInjector.commands
{
	import flash.events.Event;

	public class CommandEvent extends Event
	{
		public static const COMPLETE:String 	= 'complete';
		public static const ERROR:String 		= 'error';

		//MacroCommand
		public static const NEXT_COMMAND:String = 'nextCommand';

		public function CommandEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}