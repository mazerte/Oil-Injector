package org.mazerte.oilInjector.view.factory
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;

	public class ViewLocatorFactory
	{

		public static function factory(qualifiedClassName:String):Sprite
		{
			var klass:Class = getDefinitionByName(qualifiedClassName) as Class;
			var view:Sprite;

			try
			{
				view = new klass() as Sprite;
			}
			catch(error:Error)
			{
				throw new Error('Invalid qualifiedClassName: ' + qualifiedClassName + " " + error.toString());
			}

			return view;
		}

		/*public static function mxmlFactory(qualifiedClassName:String):IVisualElement
		{
			return factory(qualifiedClassName) as IVisualElement;
		}*/

	}
}