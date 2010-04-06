package org.mazerte.oilInjector.control.factory
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	import org.mazerte.oilInjector.OilInjectorError;
	import org.mazerte.oilInjector.control.IFrontController;

	public class FrontControllerFactory
	{
		public function FrontControllerFactory()
		{
		}

		public static function factory(qualifiedClassName:String):IFrontController
		{
			var klass:Class = getDefinitionByName(qualifiedClassName) as Class;
			var controller:IFrontController;

			try
			{
				controller = new klass() as IFrontController;
			}
			catch(error:OilInjectorError)
			{
	        	var classDescription:XML = describeType( klass ) as XML;
	        	var methodName:String = 'getInstance';
	        	if(classDescription.factory.method.(@name == methodName) != 0)
	        		return klass[methodName]() as IFrontController;
				throw new Error('Invalid qualifiedClassName: ' + qualifiedClassName);
			}
			catch(error:Error)
			{
				throw new Error('Invalid qualifiedClassName: ' + qualifiedClassName);
			}

			return controller;
		}

	}
}