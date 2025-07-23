package util 
{
	import fastByteArray.ByteArrayUtils;
	import fastByteArray.IByteArray;
	import flash.geom.Rectangle;
	
	public class PackerHelper
	{
		
		[Inline]
		public static function roundPixels20(pixels:Number):Number {
			return Math.round(pixels * 100) / 100;
		}
		
		[Inline]
		public static function readRectangle(input:IByteArray):Rectangle 
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
		
		[Inline]
		public static function writeRectangle(rectangle:Rectangle, output:IByteArray):void 
		{
			var xmin:int = rectangle.x * 20;
			var xmax:int = rectangle.width * 20;
			var ymin:int = rectangle.y * 20;
			var ymax:int = rectangle.height * 20;
			
			//if (xmin < 0 || ymin < 0 || xmax < 0 || ymax < 0)
				//throw new Error("value range error: " + xmin + ", " + ymin + ", " + xmax + ", " + ymax);
			
			//var numBits:uint = ByteArrayUtils.calculateMaxBits4(true, xmin, xmax, ymin, ymax);
			
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
	}
	
}