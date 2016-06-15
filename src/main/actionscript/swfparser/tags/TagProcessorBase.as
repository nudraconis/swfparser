package swfparser.tags 
{
	import swfdata.dataTags.SwfPackerTag;
	import swfparser.DisplayObjectContext;
	import swfparser.SwfParserContext;

	public class TagProcessorBase 
	{
		protected var currentTag:SwfPackerTag;
		protected var context:SwfParserContext;
		protected var displayObjectContext:DisplayObjectContext;
		
		public function TagProcessorBase(context:SwfParserContext) 
		{
			this.context = context;
			displayObjectContext = context.displayObjectContext;
		}
		
		public function processTag(tag:SwfPackerTag):void
		{
			currentTag = tag;
		}
	}
}