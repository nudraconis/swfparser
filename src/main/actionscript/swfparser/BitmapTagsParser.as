package swfparser 
{

	import com.codeazur.as3swf.tags.ITag;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import swfparser.tags.TagProcessorDefineBitmap;
	
	[Event(name="complete", type="flash.events.Event")]
	public class BitmapTagsParser extends EventDispatcher
	{
		private var bitmapTagProcessor:TagProcessorDefineBitmap;
		private var tagsList:Vector.<ITag>;
		
		public function BitmapTagsParser(context:SwfParserContext) 
		{
			bitmapTagProcessor = new TagProcessorDefineBitmap(context);
			bitmapTagProcessor.addEventListener(Event.COMPLETE, onTagProcessed);
		}
		
		public function processTags(tagsList:Vector.<ITag>):void
		{
			this.tagsList = tagsList;
			processNext();
		}
		
		private function onTagProcessed(e:Event):void 
		{
			processNext();
		}
		
		private function processNext():void 
		{
			if (tagsList.length > 0)
				bitmapTagProcessor.processTag(tagsList.shift());
			else
				finish();
		}
		
		private function finish():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function clear():void {
			bitmapTagProcessor.clear();
		}
		
		public function destroy():void
		{
			bitmapTagProcessor.removeEventListener(Event.COMPLETE, onTagProcessed);
		}
	}
}