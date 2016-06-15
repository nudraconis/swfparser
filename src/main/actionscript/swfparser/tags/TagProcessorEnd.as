package swfparser.tags 
{
	import flash.geom.Matrix;
	import swfdata.dataTags.SwfPackerTag;
	import swfparser.SwfParserContext;
	
	public class TagProcessorEnd extends TagProcessorBase 
	{
		
		
		public function TagProcessorEnd(context:SwfParserContext) 
		{
			super(context);
		}
		
		override public function processTag(tag:SwfPackerTag):void 
		{
			super.processTag(tag);
			
			//trace('end');
			
			if (displayObjectContext.currentDisplayObject == null)
				return;
			
			if (displayObjectContext.currentDisplayObject.transform == null)
				displayObjectContext.currentDisplayObject.setTransformMatrix(new Matrix());//because that object not on time line
					
			displayObjectContext.setCurrentDisplayObject(null);
		}
	}
}