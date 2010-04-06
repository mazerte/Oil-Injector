package org.mazerte.oilInjector.model.factory
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	import org.mazerte.oilInjector.OilInjectorError;
	import org.mazerte.oilInjector.model.IModelLocator;

	public class ModelLocatorFactory
	{

		public static function factory(qualifiedClassName:String):IModelLocator
		{
			var klass:Class = getDefinitionByName(qualifiedClassName) as Class;
			var model:IModelLocator;

			try
			{
				model = new klass() as IModelLocator;
			}
			catch(error:OilInjectorError)
			{
	        	var classDescription:XML = describeType( klass ) as XML;
	        	var methodName:String = 'getInstance';
	        	if(classDescription.factory.method.(@name == methodName) != 0)
	        		return klass[methodName]() as IModelLocator;
				throw new Error('Invalid qualifiedClassName: ' + qualifiedClassName);
			}
			catch(error:Error)
			{
				throw new Error('Invalid qualifiedClassName: ' + qualifiedClassName);
			}

			return model;
		}

	}
}