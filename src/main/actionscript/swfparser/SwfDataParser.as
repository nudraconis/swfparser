package swfparser 
{
	import com.codeazur.as3swf.SWF;
	import swfDataExporter.AS3GraphicsDataShapeExporter;
	import com.codeazur.as3swf.tags.ITag;
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
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import swfdata.BitmapLibrary;
	import swfdata.ShapeLibrary;
	import swfdata.SymbolsLibrary;
	import swfdata.atlas.AtlasDrawer;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.dataTags.SwfPackerTag;
	import swfparser.tags.TagProcessorBase;
	import swfparser.tags.TagProcessorDefineSprite;
	import swfparser.tags.TagProcessorEnd;
	import swfparser.tags.TagProcessorPlaceObject;
	import swfparser.tags.TagProcessorRemoveObject;
	import swfparser.tags.TagProcessorShapeDefinition;
	import swfparser.tags.TagProcessorShowFrame;
	import swfparser.tags.TagProcessorSymbolClass;
	import swfparser.tags.TagsRebuilder;

	public class SwfDataParser extends EventDispatcher implements ISWFDataParser
	{
		private var _context:SwfParserContext = new SwfParserContext();
		public var packerTags:Vector.<SwfPackerTag> = new Vector.<SwfPackerTag>;
		
		private var tagsProcessors:Object;
		
		private var swfTagsParser:SWF;
		private var tagProcessorShapeDefinition:TagProcessorShapeDefinition;
		private var tagsRebuilder:TagsRebuilder = new TagsRebuilder();
		private var bitmapTagsParser:BitmapTagsParser;
		
		private var onlyTagsReport:Boolean;
		private var drawAdditionalAA:Boolean;
		private var atlasSize:int;
		
		//1 - contain morph, 2 - contain bitmaps, 3 - contain bitmaps and morph
		public var erroStatus:int;
		
		/**
		 * 
		 * @param	onlyTagsReport - only check for unsupported tags/errors
		 * @param	atlasSize
		 */
		public function SwfDataParser(onlyTagsReport:Boolean = false, atlasSize:int = 2048) 
		{
			this.atlasSize = atlasSize;
			this.onlyTagsReport = onlyTagsReport;
			
			initialize();
		}
		
		private function initialize():void 
		{
			makeTagProcessorsMap();
			
			clear();
		}
		
		public function dispose():void
		{
			context.dispose();
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
				context.atlasDrawer = new AtlasDrawer(new BitmapTextureAtlas(atlasSize, atlasSize, 4), 1, 4);
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
				
			if (context.bitmapLibrary == null)
				context.bitmapLibrary = new BitmapLibrary();
			else
				context.bitmapLibrary.clear();
				
			context.clear();
				
			if (swfTagsParser)
				swfTagsParser.clear();
			else
				swfTagsParser = new SWF();
			
			if (tagProcessorShapeDefinition)
				tagProcessorShapeDefinition.clear();
				
			if (bitmapTagsParser)
			{
				bitmapTagsParser.removeEventListener(Event.COMPLETE, onBitmapTagsFinish);
				bitmapTagsParser.destroy();
			}
			
			tagProcessorShapeDefinition = new TagProcessorShapeDefinition(context, new AS3GraphicsDataShapeExporter(swfTagsParser, context.bitmapLibrary));
			
			bitmapTagsParser = new BitmapTagsParser(context);
			bitmapTagsParser.addEventListener(Event.COMPLETE, onBitmapTagsFinish);
			
			erroStatus = 0;
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
			
			
			tagProcessorShapeDefinition = new TagProcessorShapeDefinition(context, new AS3GraphicsDataShapeExporter(swfTagsParser, context.bitmapLibrary));
			//tagsProcessors[TagDefineShape.TYPE] = tagProcessorShapeDefinition;
			//tagsProcessors[TagDefineShape2.TYPE] = tagProcessorShapeDefinition;
			//tagsProcessors[TagDefineShape3.TYPE] = tagProcessorShapeDefinition;
			
			//tagsProcessors[TagDefineShape4.TYPE] = tagProcessorShapeDefinition;
			tagsProcessors[TagShowFrame.TYPE] = new TagProcessorShowFrame(context);
			
			tagsProcessors[TagSymbolClass.TYPE] = new TagProcessorSymbolClass(context);
		}
		
		public function parseSwf(data:ByteArray, drawAdditionalAA:Boolean):void
		{
			this.drawAdditionalAA = drawAdditionalAA;
			swfTagsParser.loadBytes(data);
			processData();
		}
		
		private function checkForUnsopportedTags():void
		{
			var tagsMap:Object = {};
				
			for (var i:int = 0; i < swfTagsParser.tags.length; i++)
			{
				if (tagsMap[swfTagsParser.tags[i]["constructor"]] == null)
					tagsMap[swfTagsParser.tags[i]["constructor"]] = 1;
				else
					tagsMap[swfTagsParser.tags[i]["constructor"]]++;
			}
			
			if (tagsMap[TagDefineMorphShape] != null || tagsMap[TagDefineMorphShape2] != null)
				erroStatus += 1;
		}
		
		private function processData():void 
		{	
			if (swfTagsParser.tags.length == 0)
				internal_trace("Error: NO TAGS PROCESSED");
				
			checkForUnsopportedTags();
				
			if(onlyTagsReport)
				return finish();
				
			var bitmapTags:Vector.<ITag> = new Vector.<ITag>();
			
			for (var i:int = 0; i < swfTagsParser.tags.length; i++)
			{
				var currentTag:ITag = swfTagsParser.tags[i];
				var tagType:uint = currentTag.type;
				
				if (tagType == TagDefineBits.TYPE || tagType == TagDefineBitsJPEG2.TYPE || tagType == TagDefineBitsJPEG3.TYPE || tagType == TagDefineBitsLossless.TYPE || tagType == TagDefineBitsLossless2.TYPE)
				{
					bitmapTags.push(currentTag);
				}
				
				if (swfTagsParser.tags[i].type == TagEnd.TYPE)
				{
					swfTagsParser.tags.splice(i, 1);
					i--;
				}
			}
			
			bitmapTagsParser.processTags(bitmapTags);
		}
		
		private function onBitmapTagsFinish(e:Event):void 
		{
			for (var i:int = 0; i < swfTagsParser.tags.length; i++)
			{
				var currentTag:ITag = swfTagsParser.tags[i];
				
				if (currentTag.type == TagDefineShape.TYPE || currentTag.type == TagDefineShape2.TYPE || currentTag.type == TagDefineShape3.TYPE || currentTag.type == TagDefineShape4.TYPE)
				{
					tagProcessorShapeDefinition.processTag(currentTag);
				}
			}
			
			tagsRebuilder.rebuildTags(swfTagsParser.tags, packerTags);
			
			processDisplayObject(packerTags);
			
			context.shapeLibrary.drawToAtlas(context.atlasDrawer, drawAdditionalAA);
			
			finish();
		}
		
		private function finish():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
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