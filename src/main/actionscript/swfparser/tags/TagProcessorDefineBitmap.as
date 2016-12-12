package swfparser.tags 
{
	import com.codeazur.as3swf.tags.IBitmapTag;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineBits;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import swfdata.ShapeData;
	import swfparser.SwfParserContext;
	
	[Event(name="complete", type="flash.events.Event")]
	public class TagProcessorDefineBitmap extends EventDispatcher
	{
		private var context:SwfParserContext;
		private var loader:Loader;
		
		private var tagDefineBitmap:IBitmapTag;
		private var alphaBytes:ByteArray;
		private var bitmapData:BitmapData;
		
		public function TagProcessorDefineBitmap(context:SwfParserContext) 
		{
			this.context = context;
			
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapDecoded);
		}
		
		[Inline]
		private function constrain(value:Number):int
		{
			if (value > 0xFF)
				return 0xFF;
			else if (value < 0) 
				return 0;
				
			return value;
		}
		
		private function onBitmapDecoded(e:Event):void 
		{
			bitmapData = (loader.contentLoaderInfo.content as Bitmap).bitmapData;
			
			if (alphaBytes)
			{
				var newBitmapData:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0xFFFFFFFF);
				var bitmapPixelsData:Vector.<uint> = bitmapData.getVector(bitmapData.rect);
				
				//newBitmapData.copyPixels(bitmapData, bitmapData.rect, new Point);
				var c:int = 0;
				for (var y:int = 0; y < newBitmapData.height; y++)
				{
					for (var x:int = 0; x < newBitmapData.width; x++)
					{
						var a:uint = alphaBytes[c] << 24;
						
						if (a == 255)
							continue;
							
						bitmapPixelsData[c] = (bitmapPixelsData[c] << 8 >> 8) + a;
						c++;
					}
				}
				
				newBitmapData.setVector(bitmapData.rect, bitmapPixelsData);
				bitmapData.dispose();
				
				bitmapData = newBitmapData;	
			}
			
			finish();
		}
		
		private function finish():void
		{
			var bitmapId:int = tagDefineBitmap.characterId;
			
			if (bitmapId == 0)
				trace('Error: wrong? bitmap dfinition');
				
			context.bitmapLibrary.addBitmap(bitmapId, bitmapData);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function processTag(tag:ITag):void 
		{	
			tagDefineBitmap = tag as IBitmapTag;
			
			if (tagDefineBitmap.completeBitmapData != null)
			{
				bitmapData = tagDefineBitmap.completeBitmapData;
				finish();
			}
			else
			{
				alphaBytes = null;
			
				alphaBytes = tagDefineBitmap.bitmapAlphaData
				
				if (alphaBytes)
					alphaBytes.uncompress();
					
				loader.loadBytes(tagDefineBitmap.bitmapData);
			}
		}
		
		public function clear():void 
		{
			context = null;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapDecoded);
		}
	}
}