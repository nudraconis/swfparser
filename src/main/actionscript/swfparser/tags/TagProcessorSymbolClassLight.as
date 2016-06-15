package swfparser.tags 
{
	import flash.geom.Matrix;
	import swfdata.dataTags.RawClassSymbol;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagSymbolClass;
	import swfdata.DisplayObjectData;
	import swfdata.FrameData;
	import swfdata.MovieClipData;
	import swfdata.ShapeData;
	import swfdata.SpriteData;
	import swfdata.swfdata_inner;
	import swfdata.Timeline;
	import swfparser.SwfParserContext;
	
	use namespace swfdata_inner;
	/**
	 * Тут получаем список ликейджев из библиотеки. Они идут парами characterId, linkageId
	 */
	public class TagProcessorSymbolClassLight extends TagProcessorBase 
	{
		public function TagProcessorSymbolClassLight(context:SwfParserContext) 
		{
			super(context);
		}
	
		override public function processTag(tag:SwfPackerTag):void 
		{
			super.processTag(tag);
			
			var tagSymbolClass:SwfPackerTagSymbolClass = tag as SwfPackerTagSymbolClass;
			var symbolsLength:int = tagSymbolClass.length;
			
			for (var i:int = 0; i < symbolsLength; i++)
			{
				var currentLinkage:String = tagSymbolClass.linkageList[i];
				var currentCharacter:int = tagSymbolClass.characterIdList[i];
				
				var displayObject:DisplayObjectData = context.library.getDisplayObject(currentCharacter);
				
				if (!displayObject)
				{
					trace("Error: no symbol for linkage(symbol=" + currentCharacter+ ", linkage=" + currentLinkage + ")");
					continue;
				}
				
				displayObject.libraryLinkage = currentLinkage;
				context.library.addDisplayObjectByLinkage(displayObject);
			}
		}
	}
}