package swfDataExporter 
{
	import fastByteArray.IByteArray;
	
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagDefineSprite;
	import swfdata.dataTags.SwfPackerTagEnd;
	import swfdata.dataTags.SwfPackerTagPlaceObject;
	import swfdata.dataTags.SwfPackerTagRemoveObject;
	import swfdata.dataTags.SwfPackerTagShowFrame;
	import swfdata.dataTags.SwfPackerTagSymbolClass;
	
	public class SwfTagExporter
	{
		private var exporters:Object = {};
		private var importers:Object = {};
		private var tagConstructorsObject:Object = {};
		
		public function SwfTagExporter() 
		{
			initialize();
		}
		
		public function exportTags(tags:Vector.<SwfPackerTag>, output:IByteArray):void 
		{
			var tagsCount:int = tags.length;
			
			//trace("==========================", tagsCount);
			//trace(tags.join("\n"));
			//trace("==========================");
			
			for (var i:int = 0; i < tagsCount; i++)
			{
				var exporter:SwfPackerTagExporter = exporters[tags[i].type];
				
				if (exporter)
					exporter.exportTag(tags[i], output);
				else
					throw new Error("no exporter for tag", tags[i]['constructor']);
			}
			
			tags = null;
			
			
		}
		
		public function importTags(tags:Vector.<SwfPackerTag>, input:IByteArray):void 
		{
			
			var index:int = 0;
			while (input.position != input.length)
			{
				var tag:SwfPackerTag = importSingleTag(input);
				
				if (tag == null)
					break;
				
				tags[index++] = tag;
			}
		}
		
		[Inline]
		public final function importSingleTag(input:IByteArray):SwfPackerTag
		{
			var tagType:int = input.readInt8();
			
			var importer:SwfPackerTagExporter = importers[tagType];
			
			if (importer != null)
			{
				var constructor:Class = tagConstructorsObject[tagType];
				var tag:SwfPackerTag = new constructor;
				
				importer.importTag(tag, input);
				
				return tag;
			}
			else
				throw new Error("no importer for tag " + tagType);
				
			return null;
		}
		
		private function initialize():void 
		{
			importers[ExporerTypes.END] 			= exporters[0] 		= new SwfPackerTagExporter(ExporerTypes.END);
			importers[ExporerTypes.SHOW_FRAME] 		= exporters[1] 		= new SwfPackerTagExporter(ExporerTypes.SHOW_FRAME);
			
			importers[ExporerTypes.DEFINE_SPRITE] 	= exporters[39]	= new DefineSpriteExporter(this);
			importers[ExporerTypes.PLACE_OBJECT]	= exporters[4]	= new PlaceObjectExporter();
			importers[ExporerTypes.REMOVE_OBJECT] 	= exporters[5]	= new RemoveObjectExporter();
			importers[ExporerTypes.SYMBOL_CLASS] 	= exporters[76]	= new SymbolClassExporter();
			
			tagConstructorsObject[ExporerTypes.END]				= SwfPackerTagEnd;
			tagConstructorsObject[ExporerTypes.SHOW_FRAME]		= SwfPackerTagShowFrame;
			tagConstructorsObject[ExporerTypes.DEFINE_SPRITE]	= SwfPackerTagDefineSprite;
			tagConstructorsObject[ExporerTypes.PLACE_OBJECT]	= SwfPackerTagPlaceObject;
			tagConstructorsObject[ExporerTypes.REMOVE_OBJECT]	= SwfPackerTagRemoveObject;
			tagConstructorsObject[ExporerTypes.SYMBOL_CLASS]	= SwfPackerTagSymbolClass;
		}
	}
}