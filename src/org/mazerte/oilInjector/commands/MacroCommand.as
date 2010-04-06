package org.mazerte.oilInjector.commands
{
	import flash.errors.IllegalOperationError;

	public class MacroCommand extends AbstractCommand implements ICommand
	{
		private var _isSequential:Boolean;
		private var _stopOnError:Boolean;
		private var _autoClear:Boolean;

		private var _commands:Array;
		private var _executed:uint = 0;

		public function MacroCommand(isSequential:Boolean = false, stopOnError:Boolean = false, autoClear:Boolean = true)
		{
			_isSequential = isSequential;
			_stopOnError = stopOnError;
			_autoClear = autoClear;

			_commands = new Array();
			_executed = 0;
		}

		public function get length():int
		{
			return _commands.length;
		}

		public function get index():int
		{
			return _executed;
		}

		public function addCommand(command:ICommand):void
		{
			_commands.push(command);
		}

		public function addCommandAt(command:ICommand, index:uint):void
		{
			if(index < 0 || index > _commands.length)
				throw new IllegalOperationError("L'index spécifié (" + index + ") est en dehors de limite (" + _commands.length + ")");

			_commands.splice(index, 0, command);
		}

		public function removeCommand(command:ICommand):void
		{
			var c:ICommand;
			for(var i:uint = 0; i < _commands.length; i++)
			{
				c = getCommandAt(i);
				if(c === command)
				{
					if(_autoClear)
						command.clear();

					_commands.splice(i, 1);
					break;
				}
			}
			c = null
		}

		public function removeCommandAt(index:uint):void
		{
			if(index < 0 || index > _commands.length)
				throw new IllegalOperationError("L'index spécifié (" + index + ") est en dehors de limite (" + _commands.length + ")");

			if(_autoClear)
				getCommandAt(index).clear();

			_commands.splice(index, 1);
		}

		public function getCommandAt(index:uint):ICommand
		{
			if(index < 0 || index > _commands.length)
				throw new IllegalOperationError("L'index spécifié (" + index + ") est en dehors de limite (" + _commands.length + ")");

			return _commands[index] as ICommand;
		}

		public function getCurrentCommand():ICommand
		{
			return getCommandAt(_executed);
		}

		public function getIndexByCommand(command:ICommand):uint
		{
			return null;
		}

		public function execute():void
		{
			if(_commands.length < 1)
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
			else
			{
				var command:ICommand;
				if(_isSequential)
				{
					command = getCommandAt(0);
					command.addEventListener(CommandEvent.COMPLETE, _completeHandler);
					command.addEventListener(CommandEvent.ERROR, 	_errorHandler);
					command.execute();
				}
				else
				{
					for(var i:uint = 0; i < _commands.length; i++)
					{
						command = getCommandAt(i);
						command.addEventListener(CommandEvent.COMPLETE, _completeHandler);
						command.addEventListener(CommandEvent.ERROR, 	_errorHandler);
						command.execute();
					}
				}
				addEventListener(CommandEvent.COMPLETE, _completeAllHandler);
				command = null;
			}
		}

		private function _completeHandler(event:CommandEvent):void
		{
			var command:ICommand;
			if (event && event.target && (event.target is ICommand))
			{
				command = event.target as ICommand;
				command.removeEventListener(CommandEvent.COMPLETE, 	_completeHandler);
				command.removeEventListener(CommandEvent.ERROR, 	_errorHandler);
			}

			dispatchEvent(new CommandEvent(CommandEvent.NEXT_COMMAND));

			if(_autoClear)
			{
				command = getCommandAt(_executed);
				command.clear();
			}

			_executed ++;

			if(_executed >= _commands.length)
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
			else if(_isSequential)
			{
				command = getCommandAt(_executed);
				command.addEventListener(CommandEvent.COMPLETE, _completeHandler);
				command.addEventListener(CommandEvent.ERROR, 	_errorHandler);
				command.execute();
			}
			command = null;
		}

		private function _errorHandler(event:CommandEvent):void
		{
			if (!_stopOnError)
				_completeHandler(null);
			else
				dispatchEvent(new CommandEvent(CommandEvent.ERROR));
		}

		private function _completeAllHandler(event:CommandEvent):void
		{
			_executed = 0;
			if(_autoClear)
				clear();
		}

		override public function clear():void
		{
			var command:ICommand;
			for(var i:uint = 0; i < _commands.length; i++)
			{
				command = getCommandAt(i);
				if(!command)
					continue;

				command.removeEventListener(CommandEvent.COMPLETE, 	_completeHandler);
				command.removeEventListener(CommandEvent.ERROR, 	_errorHandler);
				command.clear();

				_commands[i] = null
			}
			command = null;

			_commands = null;
			_executed = 0;
		}
	}
}