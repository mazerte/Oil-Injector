package org.mazerte.oilInjector.commands
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class DelayCommand extends AbstractCommand implements ICommand
	{
		private var _timer:Timer;

		public function DelayCommand(time:int = 1000)
		{
			_timer = new Timer(time);
			_timer.addEventListener(TimerEvent.TIMER, _timeCompleteHandler);
		}

		public function execute():void
		{
			_timer.start();
		}

		private function _timeCompleteHandler(event:TimerEvent):void
		{
			_timer.removeEventListener(TimerEvent.TIMER, _timeCompleteHandler);
			_timer = null;

			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
		}

		override public function clear():void
		{
			if(_timer)
			{
				_timer.removeEventListener(TimerEvent.TIMER, _timeCompleteHandler);
				_timer = null;
			}
		}

	}
}