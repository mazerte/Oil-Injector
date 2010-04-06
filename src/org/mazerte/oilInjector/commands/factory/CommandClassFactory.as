package org.mazerte.oilInjector.commands.factory
{
	import flash.utils.getDefinitionByName;

	public class CommandClassFactory
	{
		public function CommandClassFactory()
		{
		}

		public static function factory(qualifiedClassName:String):Class
		{
			return getDefinitionByName(qualifiedClassName) as Class
		}

	}
}