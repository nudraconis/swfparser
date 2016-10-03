package swfDataExporter 
{
	import fastByteArray.ByteArrayUtils;
	import fastByteArray.Constants;
	import fastByteArray.IByteArray;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import swfdata.ShapeLibrary;
	import swfdata.atlas.BaseSubTexture;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.atlas.TextureTransform;
	
	public class BaseSwfAtlasExporter implements ISwfAtlasExporter
	{
		protected var bitmapBytes:ByteArray = new ByteArray();
		
		public function BaseSwfAtlasExporter() 
		{
			
		}
		
		public static function roundPixels20(pixels:Number):Number {
			return Math.round(pixels * 100) / 100;
		}
		
		public function readRectangle(input:IByteArray):Rectangle 
		{
			//var bits:uint = input.readBits(5);
			
			
			var rect:Rectangle = new Rectangle();
			
			//rect.x = (input.readBits(bits));
			//rect.width = (input.readBits(bits));
			//rect.y = (input.readBits(bits));
			//rect.height = (input.readBits(bits));
			
			
			rect.x = roundPixels20(input.readInt32() / 20);
			rect.width = roundPixels20(input.readInt32() / 20);
			rect.y = roundPixels20(input.readInt32() / 20);
			rect.height = roundPixels20(input.readInt32() / 20);
			
			//trace('read rect', rect);
			
			//trace('read rectangle', rect);
			
			return rect;
		}
		
		public function writeRectangle(rectangle:Rectangle, output:IByteArray):void 
		{
			var xmin:int = rectangle.x * 20;
			var xmax:int = rectangle.width * 20;
			var ymin:int = rectangle.y * 20;
			var ymax:int = rectangle.height * 20;
			
			//if (xmin < 0 || ymin < 0 || xmax < 0 || ymax < 0)
				//throw new Error("value range error: " + xmin + ", " + ymin + ", " + xmax + ", " + ymax);
			
			var numBits:uint = ByteArrayUtils.calculateMaxBits4(true, xmin, xmax, ymin, ymax);
			
			//output.writeBits(numBits, 5);
			//output.writeBits(xmin, numBits);
			//output.writeBits(xmax, numBits);
			//output.writeBits(ymin, numBits);
			//output.writeBits(ymax, numBits);
			
			output.writeInt32(xmin);
			output.writeInt32(xmax);
			output.writeInt32(ymin);
			output.writeInt32(ymax);
			//trace('write rect', rectangle);
			//trace('write rectangle', numBits, rectangle);
		}
		
		public function readTextureTransform(input:IByteArray):TextureTransform
		{	
			var scaleX:Number = 1;
			var scaleY:Number = 1;
			
		/*	if (input.readBits(1) == 1) 
			{
				var scaleBits:uint = input.readBits(5);
				scaleX = input.readFixedBits(scaleBits);
				scaleY = input.readFixedBits(scaleBits);
			}*/
			
			if (input.readInt8() == 1)
			{
				scaleX = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
				scaleY = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			}
			
			//input.bitsReader.clear();
			
			//var translateBits:uint = input.readBits(5);
			
			//var translateX:Number = input.readBits(translateBits);
			//var translateY:Number = input.readBits(translateBits);
			
			var translateX:Number = input.readInt32();
			var translateY:Number = input.readInt32();
			
			//trace('read transform', scaleX, scaleY, translateX / 2000, translateY / 2000);
			
			return new TextureTransform(scaleX, scaleY, translateX / 2000, translateY / 2000);
		}
		
		public function writeTextureTransform(transform:TextureTransform, output:IByteArray):void
		{
			var translateX:int = transform.tx * 2000;
			var translateY:int = transform.ty * 2000;
			
			var scaleX:Number = transform.scaleX;
			var scaleY:Number = transform.scaleY;
			
			var hasScale:Boolean = (scaleX != 1) || (scaleY != 1);
			
			//output.writeBits(hasScale ? 1 : 0, 1);
			output.writeInt8(hasScale? 1:0);
			if (hasScale) 
			{
				/*var scaleBits:uint;
				if (scaleX == 0 && scaleY == 0) 
				{
					scaleBits = 1;
				} 
				else 
				{
					scaleBits = ByteArrayUtils.calculateMaxBits(true, scaleX * Constants.FIXED_PRECISSION_VALUEE, scaleY * Constants.FIXED_PRECISSION_VALUEE);
				}
				
				if (scaleX < 0 || scaleY < 0)
					throw new Error("value range error: " + scaleX + ", " + scaleY);
				
				output.writeBits(scaleBits, 5);
				output.writeFixedBits(scaleX, scaleBits);
				output.writeFixedBits(scaleY, scaleBits);*/
				
				output.writeInt32(scaleX * Constants.FIXED_PRECISSION_VALUE);
				output.writeInt32(scaleY * Constants.FIXED_PRECISSION_VALUE);
			}
			
			//output.end(false);
			
			//var translateBits:uint = ByteArrayUtils.calculateMaxBits(true, translateX, translateY);
			
			//output.writeBits(translateBits, 5);
			//output.writeBits(translateX, translateBits);
			//output.writeBits(translateY, translateBits);
			
			output.writeInt32(translateX);
			output.writeInt32(translateY);
			
			//trace('wirte trnasform', scaleX, scaleY, transform.tx, transform.ty);
		}
		
		public function exportAtlas(atlas:BitmapTextureAtlas, shapesList:ShapeLibrary, output:IByteArray):void 
		{
			var bitmap:BitmapData = atlas.data;
			var bitmapBytes:ByteArray = bitmap.getPixels(bitmap.rect);
			
			if (bitmap.width < 2 || bitmap.height < 2)
				internal_trace("Error: somethink wrong with atlas data");
			
			output.writeInt8(atlas.padding);
			output.writeInt32(bitmapBytes.length);
			output.writeInt16(bitmap.width);
			output.writeInt16(bitmap.height);
			
			output.writeBytes(bitmapBytes, 0, bitmapBytes.length);
			
			output.writeInt16(atlas.texturesCount);
			
			//trace('pre write', output.position);
			
			for each(var texture:BaseSubTexture in atlas.subTextures)
			{
				output.writeInt16(texture.id);
				
				writeTextureTransform(texture.transform, output);
				writeRectangle(texture.bounds, output);
				
				writeRectangle(shapesList.getShape(texture.id).shapeData.shapeBounds, output);
				
				//trace('write', output.position);
			}
			//output.end(false);
		}
		
		public function importAtlas(name:String, input:IByteArray, shapesList:ShapeLibrary, format:String):BaseTextureAtlas 
		{
			return null;
		}
	}
}