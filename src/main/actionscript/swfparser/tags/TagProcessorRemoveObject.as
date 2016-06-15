package swfparser.tags 
{
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagRemoveObject;
	import swfdata.SpriteData;
	import swfparser.SwfParserContext;
	
	public class TagProcessorRemoveObject extends TagProcessorBase 
	{
		
		public function TagProcessorRemoveObject(context:SwfParserContext) 
		{
			super(context);
		}
		
		override public function processTag(tag:SwfPackerTag):void 
		{
			super.processTag(tag);
			
			var tagRemoveObject:SwfPackerTagRemoveObject = tag as SwfPackerTagRemoveObject;
			var currentDisplayObject:SpriteData = displayObjectContext.currentDisplayObject;
			
			delete context.placeObjectsMap[tagRemoveObject.depth];
		}
	}
}