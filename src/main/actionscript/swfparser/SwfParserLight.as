package swfparser 
{
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.ShapeLibrary;
	import swfdata.SymbolsLibrary;
	import swfparser.tags.TagProcessorBase;
	import swfparser.tags.TagProcessorDefineSprite;
	import swfparser.tags.TagProcessorEnd;
	import swfparser.tags.TagProcessorPlaceObject;
	import swfparser.tags.TagProcessorRemoveObject;
	import swfparser.tags.TagProcessorShowFrame;
	import swfparser.tags.TagProcessorSymbolClassLight;
	import swfparser.tags.TagProcessorTextFieldDefinition;
	
	public class SwfParserLight implements ISWFDataParser 
	{
		private var _context:SwfParserContext;
		private var tagsProcessors:Object;
		private var isUseEndTag:Boolean;
		
		public function SwfParserLight(isUseEndTag:Boolean = false) 
		{
			this.isUseEndTag = isUseEndTag;
			initialize();
		}
		
		private function initialize():void 
		{
			context = new SwfParserContext();
			clear();
			
			makeTagProcessorsMap();
		}
		
		public function clear(callDestroy:Boolean = true):void 
		{
			if(context.library == null)
				context.library = new SymbolsLibrary();
			else
				context.library.clear(callDestroy);
				
			if(context.shapeLibrary == null)
				context.shapeLibrary = new ShapeLibrary();
			else
				context.shapeLibrary.clear(callDestroy);
		}
		
		private function makeTagProcessorsMap():void 
		{
			tagsProcessors = { };
			
			tagsProcessors[39] = new TagProcessorDefineSprite(context, this);
			tagsProcessors[37] = new TagProcessorTextFieldDefinition(context);
			
			if(isUseEndTag)
				tagsProcessors[0] = new TagProcessorEnd(context);
			
			var tagProcessorRemoveObject:TagProcessorRemoveObject = new TagProcessorRemoveObject(context);
			tagsProcessors[5] = tagProcessorRemoveObject;
			
			var tagProcessorPlaceObject:TagProcessorPlaceObject = new TagProcessorPlaceObject(context);
			tagsProcessors[4] = tagProcessorPlaceObject;
			
			tagsProcessors[1] = new TagProcessorShowFrame(context);
			
			tagsProcessors[76] = new TagProcessorSymbolClassLight(context);
		}
		
		public function processDisplayObject(tags:Vector.<SwfPackerTag>):void 
		{
			for (var i:int = 0; i < tags.length; i++)
			{
				var currentTag:SwfPackerTag = tags[i];
				
				var tagProcessor:TagProcessorBase = tagsProcessors[currentTag.type];
				
				if (tagProcessor != null)
					tagProcessor.processTag(currentTag);
				else
					trace('no processor for', currentTag);
			}
		}
		
		public function get context():SwfParserContext 
		{
			return _context;
		}
		
		public function set context(value:SwfParserContext):void 
		{
			_context = value;
		}
	}

}