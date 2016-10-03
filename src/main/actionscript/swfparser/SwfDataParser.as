package swfparser 
{
	import com.codeazur.as3swf.exporters.AS3GraphicsDataShapeExporter;
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.TagDefineBits;
	import com.codeazur.as3swf.tags.TagDefineBitsJPEG2;
	import com.codeazur.as3swf.tags.TagDefineBitsJPEG3;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless2;
	import com.codeazur.as3swf.tags.TagDefineMorphShape;
	import com.codeazur.as3swf.tags.TagDefineMorphShape2;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import com.codeazur.as3swf.tags.TagDefineShape2;
	import com.codeazur.as3swf.tags.TagDefineShape3;
	import com.codeazur.as3swf.tags.TagDefineShape4;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import com.codeazur.as3swf.tags.TagPlaceObject2;
	import com.codeazur.as3swf.tags.TagPlaceObject3;
	import com.codeazur.as3swf.tags.TagPlaceObject4;
	import com.codeazur.as3swf.tags.TagRemoveObject;
	import com.codeazur.as3swf.tags.TagRemoveObject2;
	import com.codeazur.as3swf.tags.TagShowFrame;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import swfdata.atlas.AtlasDrawer;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.ShapeLibrary;
	import swfdata.SymbolsLibrary;
	import swfparser.tags.TagsRebuilder;
	import swfparser.tags.TagProcessorBase;
	import swfparser.tags.TagProcessorDefineSprite;
	import swfparser.tags.TagProcessorEnd;
	import swfparser.tags.TagProcessorPlaceObject;
	import swfparser.tags.TagProcessorRemoveObject;
	import swfparser.tags.TagProcessorShapeDefinition;
	import swfparser.tags.TagProcessorShowFrame;
	import swfparser.tags.TagProcessorSymbolClass;

	public class SwfDataParser implements ISWFDataParser
	{
		private var tagsProcessors:Object;
		private var _context:SwfParserContext = new SwfParserContext();
		private var swfTagsParser:SWF;
		private var tagProcessorShapeDefinition:TagProcessorShapeDefinition;
		public var packerTags:Vector.<SwfPackerTag> = new Vector.<SwfPackerTag>;
		
		private var tagsRebuilder:TagsRebuilder = new TagsRebuilder();
		
		private var onlyTagsReport:Boolean;
		private var drawAdditionalAA:Boolean;
		
		public function SwfDataParser(onlyTagsReport:Boolean = false) 
		{
			this.onlyTagsReport = onlyTagsReport;
			
			initialize();
		}
		
		private function initialize():void 
		{
			makeTagProcessorsMap();
			
			clear();
		}
		
	
		public function clear():void 
		{
			//swfTagsParser = null;
			
			if (packerTags)
			{
				for (var i:int = 0; i < packerTags.length; i++)
				{
					packerTags[i].clear();
				}
			}
			
			packerTags.length = 0;
			
			if(context.atlasDrawer == null)
				context.atlasDrawer = new AtlasDrawer(new BitmapTextureAtlas(2048, 2048, 4), 1, 4);
			else
			{
				context.atlasDrawer.clean();
				context.atlasDrawer.targetAtlas.refrash();
			}
			
			if(context.library == null)
				context.library = new SymbolsLibrary();
			else
				context.library.clear();
				
			if(context.shapeLibrary == null)
				context.shapeLibrary = new ShapeLibrary();
			else
				context.shapeLibrary.clear();
				
			context.clear();
				
			if (swfTagsParser)
			{
				swfTagsParser.clear();
			}
			else
				swfTagsParser = new SWF();
			
			if (tagProcessorShapeDefinition)
				tagProcessorShapeDefinition.clear();
			
			tagProcessorShapeDefinition = new TagProcessorShapeDefinition(context, new AS3GraphicsDataShapeExporter(swfTagsParser));
		}
		
		private function makeTagProcessorsMap():void 
		{
			tagsProcessors = { };
			
			tagsProcessors[TagDefineSprite.TYPE] = new TagProcessorDefineSprite(context, this);
			tagsProcessors[TagEnd.TYPE] = new TagProcessorEnd(context);
			
			var tagProcessorRemoveObject:TagProcessorRemoveObject = new TagProcessorRemoveObject(context);
			tagsProcessors[TagRemoveObject.TYPE] = tagProcessorRemoveObject;
			tagsProcessors[TagRemoveObject2.TYPE] = tagProcessorRemoveObject;
			
			var tagProcessorPlaceObject:TagProcessorPlaceObject = new TagProcessorPlaceObject(context);
			tagsProcessors[TagPlaceObject.TYPE] = tagProcessorPlaceObject;
			tagsProcessors[TagPlaceObject2.TYPE] = tagProcessorPlaceObject;
			tagsProcessors[TagPlaceObject3.TYPE] = tagProcessorPlaceObject;
			tagsProcessors[TagPlaceObject4.TYPE] = tagProcessorPlaceObject;
			
			
			tagProcessorShapeDefinition = new TagProcessorShapeDefinition(context, new AS3GraphicsDataShapeExporter(swfTagsParser));
			//tagsProcessors[TagDefineShape.TYPE] = tagProcessorShapeDefinition;
			//tagsProcessors[TagDefineShape2.TYPE] = tagProcessorShapeDefinition;
			//tagsProcessors[TagDefineShape3.TYPE] = tagProcessorShapeDefinition;
			
			//tagsProcessors[TagDefineShape4.TYPE] = tagProcessorShapeDefinition;
			tagsProcessors[TagShowFrame.TYPE] = new TagProcessorShowFrame(context);
			
			tagsProcessors[TagSymbolClass.TYPE] = new TagProcessorSymbolClass(context);
		}
		
		public function parseSwf(data:ByteArray, drawAdditionalAA:Boolean):int
		{
			this.drawAdditionalAA = drawAdditionalAA;
			
			
			//swfTagsParser.addEventListener(Event.COMPLETE, onParseComplete);
			//swfTagsParser.loadBytesAsync(data);
			swfTagsParser.loadBytes(data);
			return onParseComplete();
		}
		
		private function onParseComplete(e:Event = null):int 
		{	
			var i:int;
			
			if (swfTagsParser.tags.length == 0)
				internal_trace("Error: NO TAGS PROCESSED");
				
			var tagsMap:Object = {};
				
			for (i = 0; i < swfTagsParser.tags.length; i++)
			{
				if (tagsMap[swfTagsParser.tags[i]["constructor"]] == null)
					tagsMap[swfTagsParser.tags[i]["constructor"]] = 1;
				else
					tagsMap[swfTagsParser.tags[i]["constructor"]]++;
			}
			
			var tagsState:int = 0;
			if (tagsMap[TagDefineMorphShape] != null || tagsMap[TagDefineMorphShape2] != null)
				tagsState += 1;
				
			if (tagsMap[TagDefineBits] != null || tagsMap[TagDefineBitsJPEG2] != null 
				|| tagsMap[TagDefineBitsJPEG3] != null || tagsMap[TagDefineBitsJPEG3] != null
				|| tagsMap[TagDefineBitsLossless] != null || tagsMap[TagDefineBitsLossless2] != null)
				tagsState += 2;
			
			if(onlyTagsReport)
				return tagsState;
			
			for (i = 0; i < swfTagsParser.tags.length; i++)
			{
				if (swfTagsParser.tags[i].type == TagDefineShape.TYPE || swfTagsParser.tags[i].type == TagDefineShape2.TYPE || swfTagsParser.tags[i].type == TagDefineShape3.TYPE || swfTagsParser.tags[i].type == TagDefineShape4.TYPE)
				{
					tagProcessorShapeDefinition.processTag(swfTagsParser.tags[i]);
				}
				
				if (swfTagsParser.tags[i].type == TagEnd.TYPE)
				{
					swfTagsParser.tags.splice(i, 1);
					i--;
				}
			}
			
			tagsRebuilder.rebuildTags(swfTagsParser.tags, packerTags);
			
			processDisplayObject(packerTags);
			
			context.shapeLibrary.drawToAtlas(context.atlasDrawer, drawAdditionalAA);
			
			return tagsState;
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